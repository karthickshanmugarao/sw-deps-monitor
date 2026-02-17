# sw-deps-monitor
This repository contains tools to monitor the dependencies of software libraries and avoid unnecessary dependencies to software libraries. The tools in this repository can be used in a CI/CD pipeline to perform automated checks on the dependencies of software libraries and report any unexpected dependencies. The tools can also be used to generate dependency graphs and find circular dependencies in the software libraries. The goal of this repository is to help developers maintain a clean and efficient dependency structure in their software projects.

Architects and Tech Leads can define the expected dependencies for each library in .deps files. The Tools with CICD setup can ensure that the developers adhere to the defined dependencies during the development process. This ensures adherence to the defined design and helps maintain the separation of concerns through automation.
If Developers accidentally introduce an unexpected dependency, the tools can catch it and report it in the pull request reviews, and block the merge to the main branch until the issue is resolved.
If Developers see a need to introduce a new dependency, they can align with the Leads/Architects to seek their guidance and approval and then update the .deps files accordingly to introduce the change in design. 

At any point in time, the ActualDepsList.adeps file can be reviewed by the Architects and Tech Leads to find if the dependencies are as expected in the repository. They can also visualize the dependencies by generating a graph image output from the ActualDepsList.adeps file to get a better understanding of the dependencies between the libraries in the repository. This can help them identify any potential issues with the dependencies and take necessary actions to resolve them.

## Types of Automated Checks
1. CheckModifiedLibrariesOnly - `DependenciesCheckModifiedLibraries.yml`
   - This type of checks are performed only on the libraries that are modified in the current branch. This is useful for pull request reviews to focus on the changes made in the current branch and avoid unnecessary checks on the libraries that are not modified.
   - This is added to the Pull Requests to block the merges to the main branch if any unexpected dependencies are introduced or if any circular dependencies are introduced in current branch.
2. CheckAllLibraries - `DependenciesCheckAllLibraries.yml`
   - This type of check is performed on all the libraries in the repository. This is useful to find any unexpected dependencies in the entire repository and ensure that the dependency structure is clean and efficient.
   - This is scheduled to run at regular intervals (e.g., daily once) to ensure that the repository is continuously monitored for any unexpected dependencies / circular dependencies.

## CICD Tools Available
1. scripts/generate_changed_files_list.py
   - This python script finds the list of changed files and libraries in the current branch and saves the details in the files under the folder 'CICD/Temp/CheckModifiedLVFiles/'. This is useful for pull request reviews to perform automated checks only on the libraries that are edited in the current branch.
2. CICD/AutomatedChecks/UnexpectedDepsCheck.vi
   - This VI compares the expected dependencies (defined in .deps files) with the actual dependencies (programmatically read from the lvproj files) and reports any unexpected dependencies.
   - Option `CheckChangedLibrariesOnly` is available to check only the libraries that are edited in the current branch, which is useful for pull request reviews. To use this option, the script 'scripts/generate_changed_files_list.py' need to be run before running this check.
3. CICD/AutomatedChecks/UpdateActualDepsList.vi
   - This VI updates the ActualDepsList.adeps file with the current actual dependencies read from the lvproj files.
   - Option `UpdateForChangedLibrariesOnly` is available to update the sections of the ActualDepsList.adeps that correspond to the libraries that are edited in the current branch, which is useful for pull request reviews. To use this option, the script 'scripts/generate_changed_files_list.py' need to be run before running this VI.
4. scripts/find_circular_paths.py
   - This script finds circular dependency paths in the ActualDepsList.adeps file and reports them in the console output.
5. scripts/generate_full_dependency_graph.py
   - This script generates a full dependency graph image from the ActualDepsList.adeps file to represent the dependencies observed between all the libraries in the repository. The generated image will be saved in the 'reports' folder.
6. scripts/generate_dependency_graph_for_selected_nodes.py
    - This script generates a dependency graph image output for each selected node/library passed as argument to the script. Example: `python generate_dependency_graph_for_selected_nodes.py --nodes ModuleA ModuleB`. The generated images will be saved in the 'reports' folder.
7. scripts/find_root_nodes.py
    - This script finds the root nodes/libraries in the ActualDepsList.adeps file and reports them in the console output. Root nodes are the libraries that do not have any other libraries depending on them.
    - This is useful to find the top level libraries in the project. This is useful when performing complete rebuild of the project. If we rebulid all the root nodes along with their descendants in the graph, then all the modules will be rebuilt.
    - This is useful when we want to make sure that all the modules are rebuilt after a change that affects multiple modules.
8. scripts/sort_actual_deps_list.py
    - This script sorts the ActualDepsList.adeps file in alphabetical order to make it easier to read and compare with the previous versions of the file in pull request reviews.
