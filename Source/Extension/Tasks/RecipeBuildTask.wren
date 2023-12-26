// <copyright file="RecipeBuildTask.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

import "soup" for Soup, SoupTask
import "mwasplund|Soup.Build.Utils:./Path" for Path
import "mwasplund|Soup.Build.Utils:./ListExtensions" for ListExtensions
import "mwasplund|Soup.Build.Utils:./MapExtensions" for MapExtensions
import "mwasplund|Soup.CSharp.Compiler:./BuildArguments" for BuildNullableState, BuildOptimizationLevel, BuildTargetType

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
		"InitializeDefaultsTask",
		"ResolveToolsTask",
	] }

	/// <summary>
	/// The Core Execute task
	/// </summary>
	static evaluate() {
		var globalState = Soup.globalState
		var activeState = Soup.activeState

		var context = globalState["Context"]
		var recipe = globalState["Recipe"]

		var build = MapExtensions.EnsureTable(activeState, "Build")

		// Load the input properties
		var packageRoot = Path.new(context["PackageDirectory"])
		var flavor = build["Flavor"]

		// Load Recipe properties
		var name = recipe["Name"]

		// Add the dependency static library closure to link if targeting an executable or dynamic library
		var linkLibraries = []
		if (recipe.containsKey("LinkLibraries")) {
			for (value in ListExtensions.ConvertToPathList(recipe["LinkLibraries"])) {
				// If relative then resolve to working directory
				if (value.HasRoot) {
					linkLibraries.add(value)
				} else {
					linkLibraries.add(packageRoot + value)
				}
			}
		}

		// Add the dependency runtime dependencies closure if present
		if (recipe.containsKey("RuntimeDependencies")) {
			var runtimeDependencies = []
			if (build.containsKey("RuntimeDependencies")) {
				runtimeDependencies = ListExtensions.ConvertToPathList(build["RuntimeDependencies"])
			}

			for (value in ListExtensions.ConvertToPathList(recipe["RuntimeDependencies"])) {
				// If relative then resolve to working directory
				if (value.HasRoot) {
					runtimeDependencies.add(value)
				} else {
					runtimeDependencies.add(packageRoot + value)
				}
			}

			build["RuntimeDependencies"] = ListExtensions.ConvertFromPathList(runtimeDependencies)
		}

		// Load the extra library paths provided to the build system
		var libraryPaths = []

		// Combine the defines with the default set and the platform
		var preprocessorDefinitions = []
		if (recipe.containsKey("Defines")) {
			preprocessorDefinitions = recipe["Defines"]
		}

		preprocessorDefinitions.add("SOUP_BUILD")

		// Build up arguments to build this individual recipe
		var targetDirectory = Path.new(context["TargetDirectory"])
		var binaryDirectory = Path.new("bin/")
		var objectDirectory = Path.new("obj/")

		// Load the source files if present
		var sourceFiles = []
		if (recipe.containsKey("Source")) {
			sourceFiles = recipe["Source"]
		}

		// Check for warning settings
		var enableWarningsAsErrors = true
		if (recipe.containsKey("EnableWarningsAsErrors")) {
			enableWarningsAsErrors = recipe["EnableWarningsAsErrors"]
		}

		// Check for nullable settings, default to enabled
		var nullableState = BuildNullableState.Enabled
		if (recipe.containsKey("Nullable")) {
			nullableState = RecipeBuildTask.ParseNullable(recipe["Nullable"])
		}

		// Set the correct optimization level for the requested flavor
		var optimizationLevel = BuildOptimizationLevel.None
		var generateSourceDebugInfo = false
		if (flavor == "Debug") {
			// preprocessorDefinitions.add("DEBUG")
			generateSourceDebugInfo = true
		} else if (flavor == "DebugRelease") {
			preprocessorDefinitions.add("RELEASE")
			generateSourceDebugInfo = true
			optimizationLevel = BuildOptimizationLevel.Speed
		} else if (flavor == "Release") {
			preprocessorDefinitions.add("RELEASE")
			optimizationLevel = BuildOptimizationLevel.Speed
		} else {
			Fiber.abort("Unknown build flavor: %(flavor)")
		}

		build["TargetName"] = name
		build["SourceRootDirectory"] = packageRoot.toString
		build["TargetRootDirectory"] = targetDirectory.toString
		build["ObjectDirectory"] = objectDirectory.toString
		build["BinaryDirectory"] = binaryDirectory.toString
		build["OptimizationLevel"] = optimizationLevel
		build["GenerateSourceDebugInfo"] = generateSourceDebugInfo

		ListExtensions.Append(
			MapExtensions.EnsureList(build, "LinkLibraries"),
			ListExtensions.ConvertFromPathList(linkLibraries))
		ListExtensions.Append(
			MapExtensions.EnsureList(build, "PreprocessorDefinitions"),
			preprocessorDefinitions)
		ListExtensions.Append(
			MapExtensions.EnsureList(build, "LibraryPaths"),
			ListExtensions.ConvertFromPathList(libraryPaths))
		ListExtensions.Append(
			MapExtensions.EnsureList(build, "Source"),
			sourceFiles)

		build["EnableWarningsAsErrors"] = enableWarningsAsErrors
		build["NullableState"] = nullableState

		// Convert the recipe type to the required build type
		var targetType = BuildTargetType.Library
		if (recipe.containsKey("Type")) {
			targetType = RecipeBuildTask.ParseType(recipe["Type"])
		}

		build["TargetType"] = targetType
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
