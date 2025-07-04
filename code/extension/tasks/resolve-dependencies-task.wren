// <copyright file="resolve-tools-task.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

import "soup" for Soup, SoupTask
import "Soup|Build.Utils:./list-extensions" for ListExtensions
import "Soup|Build.Utils:./map-extensions" for MapExtensions

/// <summary>
/// The resolve dependencies build task that knows how to combine all previous state
/// into the active state.
/// </summary>
class ResolveDependenciesTask is SoupTask {
	/// <summary>
	/// Get the run before list
	/// </summary>
	static runBefore { [
		"BuildTask",
	] }

	/// <summary>
	/// Get the run after list
	/// </summary>
	static runAfter { [] }

	/// <summary>
	/// The Core Execute task
	/// </summary>
	static evaluate() {
		var activeState = Soup.activeState
		var globalState = Soup.globalState

		if (globalState.containsKey("Dependencies")) {
			var dependenciesTable = globalState["Dependencies"]
			if (dependenciesTable.containsKey("Runtime")) {
				var runtimeDependenciesTable = dependenciesTable["Runtime"]
				var buildTable = MapExtensions.EnsureTable(activeState, "Build")

				for (dependencyName in runtimeDependenciesTable.keys) {
					// Combine the core dependency build inputs for the core build task
					Soup.info("Combine Runtime Dependency: %(dependencyName)")
					var dependencyTable = runtimeDependenciesTable[dependencyName]
					var dependencySharedStateTable = dependencyTable["SharedState"]

					if (dependencySharedStateTable.containsKey("Build")) {
						var dependencyBuildTable = dependencySharedStateTable["Build"]

						if (dependencyBuildTable.containsKey("RuntimeDependencies")) {
							var runtimeDependencies = dependencyBuildTable["RuntimeDependencies"]
							ListExtensions.Append(
								MapExtensions.EnsureList(buildTable, "RuntimeDependencies"),
								runtimeDependencies)
						}

						if (dependencyBuildTable.containsKey("LinkDependencies")) {
							var linkDependencies = dependencyBuildTable["LinkDependencies"]
							ListExtensions.Append(
								MapExtensions.EnsureList(buildTable, "LinkDependencies"),
								linkDependencies)
						}
					}
				}
			}

			if (dependenciesTable.containsKey("RuntimeReference")) {
				var runtimeDependenciesTable = dependenciesTable["RuntimeReference"]
				var buildTable = MapExtensions.EnsureTable(activeState, "Build")

				for (dependencyName in runtimeDependenciesTable.keys) {
					// Combine the core dependency build inputs for the core build task
					Soup.info("Combine Runtime Reference Dependency: %(dependencyName)")
					var dependencyTable = runtimeDependenciesTable[dependencyName]
					var dependencySharedStateTable = dependencyTable["SharedState"]

					if (dependencySharedStateTable.containsKey("Build")) {
						var dependencyBuildTable = dependencySharedStateTable["Build"]

						// Only copy over the runtime deps, do not include the assmeblies in the build
						if (dependencyBuildTable.containsKey("RuntimeDependencies")) {
							var runtimeDependencies = dependencyBuildTable["RuntimeDependencies"]
							ListExtensions.Append(
								MapExtensions.EnsureList(buildTable, "RuntimeDependencies"),
								runtimeDependencies)
						}
					}
				}
			}
		}
	}
}
