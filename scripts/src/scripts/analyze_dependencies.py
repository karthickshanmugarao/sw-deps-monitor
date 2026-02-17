import argparse
import configparser
import os
import sys
from typing import Dict, Optional, List

import networkx as nx
import plotly.graph_objects as go
import plotly.io as pio


def load_graph_from_adeps(path: str) -> nx.DiGraph:
    """
    Parses .adeps (INI-style) file(s) and returns a NetworkX Directed Graph.
    If path is a directory, loads all .adeps files in it.
    Sections are nodes, and keys within sections are outgoing edges (dependencies).
    """
    if not os.path.exists(path):
        raise FileNotFoundError(f"Path not found: {path}")

    files = []
    if os.path.isdir(path):
        for root, _, filenames in os.walk(path):
            for filename in filenames:
                if filename.endswith(".adeps"):
                    files.append(os.path.join(root, filename))
    else:
        files.append(path)

    config = configparser.ConfigParser(allow_no_value=True)
    # Preserve case sensitivity for keys (node names)
    config.optionxform = str
    config.read(files)

    G = nx.DiGraph()

    for section in config.sections():
        # Add the section as a node (even if it has no dependencies)
        G.add_node(section)
        # Add edges for each dependency
        for dependency in config[section]:
            G.add_edge(section, dependency)

    return G


def check_circular_paths(G: nx.DiGraph) -> None:
    """
    Checks for cycles in the graph. Raises an Exception if a cycle is found.
    """
    cycles = list(nx.simple_cycles(G))
    if cycles:
        raise Exception(f"Circular dependencies detected: {cycles}")

def find_root_nodes(G: nx.DiGraph) -> List[str]:
    """
    Finds nodes in the graph that have no incoming edges (callers).
    """
    return [n for n, d in G.in_degree() if d == 0]


def plot_graph(
    G: nx.DiGraph, output_path: str, title: str = "Dependency Graph", node_colors: Optional[Dict[str, str]] = None
) -> None:
    """
    Plots the directed graph using Plotly and saves it to an image file.
    """
    # Calculate layout for node positions
    pos = nx.spring_layout(G, seed=42, k=0.5, iterations=50)

    edge_x = []
    edge_y = []
    
    # Create edge traces
    for edge in G.edges():
        x0, y0 = pos[edge[0]]
        x1, y1 = pos[edge[1]]
        edge_x.extend([x0, x1, None])
        edge_y.extend([y0, y1, None])

    edge_trace = go.Scatter(
        x=edge_x,
        y=edge_y,
        line=dict(width=1, color="#888"),
        hoverinfo="none",
        mode="lines",
    )

    node_x = []
    node_y = []
    node_text = []
    node_color_list = []
    default_color = "#1f77b4"  # Muted blue

    for node in G.nodes():
        x, y = pos[node]
        node_x.append(x)
        node_y.append(y)
        node_text.append(node)
        if node_colors and node in node_colors:
            node_color_list.append(node_colors[node])
        else:
            node_color_list.append(default_color)

    node_trace = go.Scatter(
        x=node_x,
        y=node_y,
        mode="markers+text",
        hoverinfo="text",
        text=node_text,
        textposition="top center",
        marker=dict(showscale=False, color=node_color_list, size=15, line_width=2),
    )

    fig = go.Figure(
        data=[edge_trace, node_trace],
        layout=go.Layout(
            title=dict(text=title, font=dict(size=16)),
            showlegend=False,
            hovermode="closest",
            margin=dict(b=20, l=5, r=5, t=40),
            xaxis=dict(showgrid=False, zeroline=False, showticklabels=False),
            yaxis=dict(showgrid=False, zeroline=False, showticklabels=False),
        ),
    )
    # Disable mathjax to prevent potential Kaleido hangs/errors on Windows
    pio.defaults.mathjax = None
    fig.write_image(output_path)


def analyze_node_and_plot(G: nx.DiGraph, node_name: str, output_path: str) -> None:
    """
    Finds descendants and callers (ancestors) of a node and plots the subgraph.
    """
    if node_name not in G:
        print(f"Error: Node '{node_name}' not found in the graph.")
        return

    descendants = nx.descendants(G, node_name)
    ancestors = nx.ancestors(G, node_name)

    print(f"--- Analysis for Node: {node_name} ---")
    print(f"Callers (Ancestors): {', '.join(ancestors) if ancestors else 'None'}")
    print(f"Dependencies (Descendants): {', '.join(descendants) if descendants else 'None'}")

    # Create subgraph including the node, its ancestors, and its descendants
    nodes_of_interest = {node_name} | descendants | ancestors
    sub_G = G.subgraph(nodes_of_interest)

    # Assign colors
    node_colors = {}
    for n in sub_G.nodes():
        if n == node_name:
            node_colors[n] = "red"  # Selected Node
        elif n in ancestors:
            node_colors[n] = "green"  # Callers
        elif n in descendants:
            node_colors[n] = "blue"  # Descendants
        else:
            node_colors[n] = "gray"

    plot_graph(
        sub_G,
        output_path=output_path,
        title=f"Subgraph for {node_name} (Red=Target, Green=Callers, Blue=Descendants)",
        node_colors=node_colors,
    )


def main():
    parser = argparse.ArgumentParser(description="Analyze dependency graph from .adeps file")
    parser.add_argument(
        "--file",
        type=str,
        # required=True,
        default="Source/ActualDependencies",
        help="Path to the .adeps file or directory (e.g., Source/ActualDependencies)",
    )
    parser.add_argument(
        "--node",
        type=str,
        help="Optional: Name of the node to analyze (descendants/callers)",
    )
    parser.add_argument(
        "--root",
        type=str,
        default=".",
        help="Root directory to save reports (default: current directory)",
    )

    args = parser.parse_args()

    try:
        G = load_graph_from_adeps(args.file)
        print(f"Graph loaded: {G.number_of_nodes()} nodes, {G.number_of_edges()} edges.")

        check_circular_paths(G)
        print("No circular paths detected.")

        reports_dir = os.path.join(args.root, "reports")
        os.makedirs(reports_dir, exist_ok=True)

        if args.node:
            output_path = os.path.join(reports_dir, f"{args.node}_dependency_graph.png")
            analyze_node_and_plot(G, args.node, output_path)
        else:
            output_path = os.path.join(reports_dir, "full_dependency_graph.png")
            plot_graph(G, output_path, title="Full Dependency Graph")

        print(f"Graph exported to: {os.path.abspath(output_path)}")

    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()