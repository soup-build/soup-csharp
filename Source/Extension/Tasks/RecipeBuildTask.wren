// <copyright file="RecipeBuildTask.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

import "soup" for Soup, SoupTask
import "Soup.CSharp.Compiler:./BuildArguments" for BuildNullableState, BuildOptimizationLevel, BuildTargetType
import "Soup.Build.Utils:./ListExtensions" for ListExtensions
import "Soup.Build.Utils:./MapExtensions" for MapExtensions
import "Soup.Build.Utils:./Path" for Path

/// <summary>
/// The recipe build task that knows how to build a single recipe
/// </summary>
class RecipeBuildTask is SoupTask {
	/// <summary>
	/// Get the run before list
	/// </summary>
	static runBefore { [
		"BuildTask",
	] }

	/// <summary>
	/// Get the run after list
	/// </summary>
	static runAfter { [
		"ResolveToolsTask",
	] }

	/// <summary>
	/// The Core Execute task
	/// </summary>
	static evaluate() {
		var activeState = Soup.activeState
		var globalState = Soup.globalState

		var parametersTable = globalState["Parameters"]
		var contextTable = globalState["Context"]
		var recipeTable = globalState["Recipe"]
		var buildTable = MapExtensions.EnsureTable(activeState, "Build")

		// Load the input properties
		var compilerName = parametersTable["Compiler"]
		var packageRoot = Path.new(contextTable["PackageDirectory"])
		var buildFlavor = parametersTable["Flavor"]

		// Load Recipe properties
		var name = recipeTable["Name"]

		// Add the dependency static library closure to link if targeting an executable or dynamic library
		var linkLibraries = []
		if (recipeTable.containsKey("LinkLibraries")) {
			for (value in ListExtensions.ConvertToPathList(recipeTable["LinkLibraries"])) {
				// If relative then resolve to working directory
				if (value.HasRoot) {
					linkLibraries.add(value)
				} else {
					linkLibraries.add(packageRoot + value)
				}
			}
		}

		// Add the dependency runtime dependencies closure if present
		if (recipeTable.containsKey("RuntimeDependencies")) {
			var runtimeDependencies = []
			if (buildTable.containsKey("RuntimeDependencies")) {
				runtimeDependencies = ListExtensions.ConvertToPathList(buildTable["RuntimeDependencies"])
			}

			for (value in ListExtensions.ConvertToPathList(recipeTable["RuntimeDependencies"])) {
				// If relative then resolve to working directory
				if (value.HasRoot) {
					runtimeDependencies.add(value)
				} else {
					runtimeDependencies.add(packageRoot + value)
				}
			}

			buildTable["RuntimeDependencies"] = runtimeDependencies
		}

		// Load the extra library paths provided to the build system
		var libraryPaths = []

		// Combine the defines with the default set and the platform
		var preprocessorDefinitions = []
		if (recipeTable.containsKey("Defines")) {
			preprocessorDefinitions = recipeTable["Defines"]
		}

		preprocessorDefinitions.add("SOUP_BUILD")

		// Build up arguments to build this individual recipe
		var targetDirectory = Path.new(contextTable["TargetDirectory"])
		var binaryDirectory = Path.new("bin/")
		var objectDirectory = Path.new("obj/")

		// Load the source files if present
		var sourceFiles = []
		if (recipeTable.containsKey("Source")) {
			sourceFiles = recipeTable["Source"]
		}

		// Check for warning settings
		var enableWarningsAsErrors = true
		if (recipeTable.containsKey("EnableWarningsAsErrors")) {
			enableWarningsAsErrors = recipeTable["EnableWarningsAsErrors"]
		}

		// Check for nullable settings, default to enabled
		var nullableState = BuildNullableState.Enabled
		if (recipeTable.containsKey("Nullable")) {
			nullableState = RecipeBuildTask.ParseNullable(recipeTable["Nullable"])
		}

		// Set the correct optimization level for the requested flavor
		var optimizationLevel = BuildOptimizationLevel.None
		var generateSourceDebugInfo = false
		if (buildFlavor == "debug") {
			// preprocessorDefinitions.add("DEBUG")
			generateSourceDebugInfo = true
		} else if (buildFlavor == "debugrelease") {
			preprocessorDefinitions.add("RELEASE")
			generateSourceDebugInfo = true
			optimizationLevel = BuildOptimizationLevel.Speed
		} else if (buildFlavor == "release") {
			preprocessorDefinitions.add("RELEASE")
			optimizationLevel = BuildOptimizationLevel.Speed
		} else {
			Fiber.abort("Unknown build flavor type.")
		}

		buildTable["TargetName"] = name
		buildTable["SourceRootDirectory"] = packageRoot.toString
		buildTable["TargetRootDirectory"] = targetDirectory.toString
		buildTable["ObjectDirectory"] = objectDirectory.toString
		buildTable["BinaryDirectory"] = binaryDirectory.toString
		buildTable["OptimizationLevel"] = optimizationLevel
		buildTable["GenerateSourceDebugInfo"] = generateSourceDebugInfo

		ListExtensions.Append(
			MapExtensions.EnsureList(buildTable, "LinkLibraries"),
			linkLibraries)
		ListExtensions.Append(
			MapExtensions.EnsureList(buildTable, "PreprocessorDefinitions"),
			preprocessorDefinitions)
		ListExtensions.Append(
			MapExtensions.EnsureList(buildTable, "LibraryPaths"),
			libraryPaths)
		ListExtensions.Append(
			MapExtensions.EnsureList(buildTable, "Source"),
			sourceFiles)

		buildTable["EnableWarningsAsErrors"] = enableWarningsAsErrors
		buildTable["NullableState"] = nullableState

		// Convert the recipe type to the required build type
		var targetType = BuildTargetType.Library
		if (recipeTable.containsKey("Type")) {
			targetType = RecipeBuildTask.ParseType(recipeTable["Type"])
		}

		buildTable["TargetType"] = targetType
	}

	static ParseType(value) {
		if (value == "Executable") {
			return BuildTargetType.Executable
		} else if (value == "Library") {
			return BuildTargetType.Library
		} else {
			Fiber.abort("Unknown target type value.")
		}
	}

	static ParseNullable(value) {
		if (value == "Enabled") {
			return BuildNullableState.Enabled
		} else if (value == "Disabled") {
			return BuildNullableState.Disabled
		} else if (value == "Warnings") {
			return BuildNullableState.Warnings
		} else if (value == "Annotations") {
			return BuildNullableState.Annotations
		} else {
			Fiber.abort("Unknown nullable state value.")
		}
	}
}
