# sw-deps-monitor
This repository contains tools to monitor the dependencies of software libraries and avoid unnecessary dependencies to software libraries. The tools in this repository can be used in a CI/CD pipeline to perform automated checks on the dependencies of software libraries and report any unexpected dependencies. The tools can also be used to generate dependency graphs and find circular dependencies in the software libraries. The goal of this repository is to help developers maintain a clean and efficient dependency structure in their software projects.

Architects and Tech Leads can define the expected dependencies for each library in .deps files. The Tools with CICD setup can ensure that the developers adhere to the defined dependencies during the development process. This ensures adherence to the defined design and helps maintain the separation of concerns through automation.

If Developers accidentally introduce an unexpected dependency, the tools can catch it and report it in the pull request reviews, and block the merge to the main branch until the issue is resolved.

If Developers see a need to introduce a new dependency, they can align with the Leads/Architects to seek their guidance and approval and then update the .deps files accordingly to introduce the change in design. 

At any point in time, the ActualDepsList.adeps file can be reviewed by the Architects and Tech Leads to find if the dependencies are as expected in the repository. They can also visualize the dependencies by generating a graph image output from the ActualDepsList.adeps file to get a better understanding of the dependencies between the libraries in the repository. This can help them identify any potential issues with the dependencies and take necessary actions to resolve them.

## Types of Automated Checks

| # | Check Type | Workflow File | Description |
|:--|:---|:---|:---|
| 1 | **Check Modified Libraries Only** | `DependenciesCheckModifiedLibraries.yml` | Performs checks only on libraries modified in the current branch. Used in Pull Requests to block merges if unexpected or circular dependencies are introduced. |
| 2 | **Check All Libraries** | `DependenciesCheckAllLibraries.yml` | Performs checks on all libraries in the repository. Scheduled to run at regular intervals (e.g., daily) to continuously monitor the entire repository. |

## Automation Tools Available

| # | Tool | Description |
|:--|:---|:---|
| 1 | `scripts/generate_changed_files_list.py` | Finds the list of changed files and libraries in the current branch and saves the details. This is useful for pull request reviews to perform automated checks only on the libraries that are edited in the current branch. |
| 2 | `CICD/AutomatedChecks/UnexpectedDepsCheck.vi` | Compares the expected dependencies (defined in `.deps` files) with the actual dependencies (read from `.lvproj` files) and reports any unexpected dependencies. It can be configured to check only modified libraries. |
| 3 | `CICD/AutomatedChecks/UpdateActualDepsList.vi` | Updates the `ActualDepsList.adeps` file with the current actual dependencies. It can be configured to update only the sections corresponding to modified libraries. |
| 4 | `scripts/find_circular_paths.py` | Finds and reports circular dependency paths from the `ActualDepsList.adeps` file. |
| 5 | `scripts/generate_full_dependency_graph.py` | Generates a full dependency graph image from `ActualDepsList.adeps` to visualize dependencies between all libraries. |
| 6 | `scripts/generate_dependency_graph_for_selected_nodes.py` | Generates a dependency graph image for specified nodes/libraries. |
| 7 | `scripts/find_root_nodes.py` | Finds and reports root nodes (libraries with no incoming dependencies). This is useful for identifying top-level libraries for complete project rebuilds. |
| 8 | `scripts/sort_actual_deps_list.py` | Sorts the `ActualDepsList.adeps` file alphabetically, making it easier to read and compare in pull request reviews. |
| 9 | `scripts/calculate_coupling_metrics.py` | Calculates Afferent Coupling (Ca), Efferent Coupling (Ce), and Instability (I) for each module. It provides a console table and a markdown report, which are useful for assessing architectural health. |
