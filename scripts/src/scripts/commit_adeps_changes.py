import argparse
import os
import subprocess
import sys


def run_command(command, check=True):
    """Runs a command, prints its output, and returns the stripped stdout."""
    print(f"Running command: {' '.join(command)}")
    try:
        result = subprocess.run(
            command, capture_output=True, text=True, check=check, encoding="utf-8"
        )
        if result.stdout:
            print(result.stdout)
        if result.stderr:
            print(result.stderr, file=sys.stderr)
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"Error running command: {' '.join(command)}", file=sys.stderr)
        print(e.stdout, file=sys.stderr)
        print(e.stderr, file=sys.stderr)
        raise


def main():
    parser = argparse.ArgumentParser(description="Commit dependency updates to the current PR branch if needed.")
    parser.add_argument("--workspace", required=True, help="GitHub workspace path.")
    parser.add_argument("--deps-file-path", required=True, help="Relative path to the dependency file to check.")
    parser.add_argument("--branch", required=True, help="The branch to commit and push to.")
    args = parser.parse_args()

    os.chdir(args.workspace)

    # 1. Check for changes
    status_output = run_command(["git", "status", "--porcelain", args.deps_file_path])
    if not status_output:
        print(f"No changes detected in {args.deps_file_path}. Nothing to commit.")
        return

    print(f"Changes detected in {args.deps_file_path}. Proceeding to commit.")

    # 2. Configure Git
    run_command(["git", "config", "user.name", "github-actions[bot]"])
    run_command(["git", "config", "user.email", "41898282+github-actions[bot]@users.noreply.github.com"])

    # 3. Add, commit, and push changes to the existing PR branch
    run_command(["git", "add", args.deps_file_path])
    run_command(["git", "commit", "-m", "chore: [Automated] Update actual dependencies list"])
    run_command(["git", "push", "origin", f"HEAD:{args.branch}"])

    print(f"Successfully committed and pushed changes to branch '{args.branch}'.")

if __name__ == "__main__":
    main()