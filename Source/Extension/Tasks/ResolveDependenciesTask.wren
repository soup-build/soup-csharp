// <copyright file="ResolveToolsTask.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

import "soup" for Soup, SoupTask
import "Soup.Build.Utils:./MapExtensions" for MapExtensions

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
	]}

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

		var recipeTable = globalState["Recipe"]
		var parametersTable = globalState["Parameters"]
		var buildTable = MapExtensions.EnsureTable(activeState, "Build")

		if (globalState.containsKey("Dependencies")) {
			var dependenciesTable = globalState["Dependencies"]
			if (dependenciesTable.containsKey("Runtime")) {
				var runtimeDependenciesTable = dependenciesTable["Runtime"]

				for (dependencyName in runtimeDependenciesTable.keys) {
					// Combine the core dependency build inputs for the core build task
					Soup.info("Combine Runtime Dependency: %(dependencyName)")
					var dependencyTable = runtimeDependenciesTable[dependencyName]

					if (dependencyTable.containsKey("Build")) {
						var dependencyBuildTable = dependencyTable["Build"]
						var dependencyReference = ResolveDependenciesTask.GetRuntimeDependencyParameterReference(parametersTable, dependencyName)
						var dependencyRecipeReference = ResolveDependenciesTask.GetRuntimeDependencyReference(recipeTable, dependencyReference)

						if (!dependencyRecipeReference["ExcludeRuntime"]) {
							if (dependencyBuildTable.containsKey("RuntimeDependencies")) {
								var runtimeDependencies = dependencyBuildTable["RuntimeDependencies"]
								buildTable.EnsureValueList(this.factory, "RuntimeDependencies").append(runtimeDependencies)
							}
						} else {
							Soup.info("Excluding Runtime dependency content: %(dependencyName)")
						}

						if (dependencyBuildTable.containsKey("LinkDependencies")) {
							var linkDependencies = dependencyBuildTable["LinkDependencies"]
							buildTable.EnsureValueList(this.factory, "LinkDependencies").append(linkDependencies)
						}
					}
				}
			}
		}
	}

	static GetRuntimeDependencyReference(recipeTable, dependencyReference) {
		if (recipeTable.containsKey("Dependencies")) {
			var dependenciesTable = recipeTable["Dependencies"]
			if (dependenciesTable.containsKey("Runtime")) {
				var runtimeDependenciesList = dependenciesTable["Runtime"]
				for (dependencyValue in runtimeDependenciesList) {
					var dependency = ResolveDependenciesTask.ParseRecipeDependency(dependencyValue)
					if (dependency["Reference"] == dependencyReference) {
						return dependency
					}
				}

				Fiber.abort("Could not find a Runtime Dependency.")
			} else {
				Fiber.abort("Missing Dependencies value in Recipe Table.")
			}
		} else {
			Fiber.abort("Missing Dependencies value in Recipe Table.")
		}
	}

	static ParseRecipeDependency(dependency) {
		// A dependency can either be a string or a table with reference key
		if (dependency is string) {
			return { "Reference": dependency, "ExcludeRuntime": false }
		} else if (dependency is map) {
			var valueTable = dependency

			// Check for optional fields
			var excludeRuntime = false
			if (valueTable.containsKey("ExcludeRuntime")) {
				excludeRuntime = valueTable["ExcludeRuntime"]
			}

			// Get the require fields
			if (valueTable.containsKey("Reference")) {
				var referenceValue = valueTable["Reference"]
				if (referenceValue.IsString()) {
					return { "Reference": referenceValue, "ExcludeRuntime": excludeRuntime }
				} else {
					Fiber.abort("Recipe dependency Reference must be type String.")
				}
			} else {
				Fiber.abort("Recipe dependency table missing required Reference value.")
			}
		} else {
			Fiber.abort("Unknown Recipe dependency type.")
		}
	}

	/// <summary>
	/// Find the original reference for the given dependency package name
	/// </summary>
	static GetRuntimeDependencyParameterReference(parametersTable, name) {
		if (parametersTable.containsKey("Dependencies")) {
			var dependenciesTable = parametersTable["Dependencies"]
			if (dependenciesTable.containsKey("Runtime")) {
				var runtimeDependenciesTable = dependenciesTable["Runtime"]
				for (dependencyValue in runtimeDependenciesTable) {
					if (dependencyValue.Key == name) {
						return ResolveDependenciesTask.ParseParametersDependency(dependencyValue.Value)
					}
				}

				Fiber.abort("Could not find a Runtime Dependency.")
			} else {
				Fiber.abort("Missing Dependencies value in Recipe Table.")
			}
		} else {
			Fiber.abort("Missing Dependencies value in Recipe Table.")
		}
	}

	static ParseParametersDependency(dependency) {
		if (dependency.IsTable()) {
			var valueTable = dependency

			// Get the require fields
			if (valueTable.containsKey("Reference")) {
				var referenceValue = valueTable["Reference"]
				if (referenceValue.IsString()) {
					return referenceValue
				} else {
					Fiber.abort("Recipe dependency Reference must be type String.")
				}
			} else {
				Fiber.abort("Parameter dependency table missing required Reference value.")
			}
		} else {
			Fiber.abort("Unknown Parameters dependency type.")
		}
	}
}
