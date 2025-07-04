// <copyright file="recipe-build-task.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

import "soup" for Soup, SoupTask
import "Soup|Build.Utils:./path" for Path
import "Soup|Build.Utils:./list-extensions" for ListExtensions
import "Soup|Build.Utils:./map-extensions" for MapExtensions
import "Soup|CSharp.Compiler:./build-options" for BuildNullableState, BuildTargetType

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
		var defineConstants = []
		if (recipe.containsKey("Defines")) {
			defineConstants = recipe["Defines"]
		}

		// Build up arguments to build this individual recipe
		var targetDirectory = Path.new(context["TargetDirectory"])
		var binaryDirectory = Path.new("bin/")
		var objectDirectory = Path.new("obj/")

		// Load the source files if present
		var sourceFiles = null
		if (recipe.containsKey("Source")) {
			sourceFiles = recipe["Source"]
		}

		// Check for unsafe settings
		var allowUnsafeBlocks = false
		if (recipe.containsKey("AllowUnsafeBlocks")) {
			allowUnsafeBlocks = recipe["AllowUnsafeBlocks"]
		}

		// Check for warning settings
		var treatWarningsAsErrors = true
		if (recipe.containsKey("TreatWarningsAsErrors")) {
			treatWarningsAsErrors = recipe["TreatWarningsAsErrors"]
		}

		// Check for nullable settings, default to enabled
		var nullableState = BuildNullableState.Enabled
		if (recipe.containsKey("Nullable")) {
			nullableState = RecipeBuildTask.ParseNullable(recipe["Nullable"])
		}

		build["TargetName"] = name
		build["SourceRootDirectory"] = packageRoot.toString
		build["TargetRootDirectory"] = targetDirectory.toString
		build["ObjectDirectory"] = objectDirectory.toString
		build["BinaryDirectory"] = binaryDirectory.toString

		ListExtensions.Append(
			MapExtensions.EnsureList(build, "LinkLibraries"),
			ListExtensions.ConvertFromPathList(linkLibraries))
		ListExtensions.Append(
			MapExtensions.EnsureList(build, "DefineConstants"),
			defineConstants)
		ListExtensions.Append(
			MapExtensions.EnsureList(build, "LibraryPaths"),
			ListExtensions.ConvertFromPathList(libraryPaths))
		if (sourceFiles != null) {
			ListExtensions.Append(
				MapExtensions.EnsureList(build, "Source"),
				sourceFiles)
		}

		build["AllowUnsafeBlocks"] = allowUnsafeBlocks
		build["TreatWarningsAsErrors"] = treatWarningsAsErrors
		build["NullableState"] = nullableState

		// Convert the recipe type to the required build type
		var targetType = BuildTargetType.Library
		if (recipe.containsKey("Type")) {
			targetType = RecipeBuildTask.ParseType(recipe["Type"])
		}

		build["TargetType"] = targetType

		var targetFramework = null
		if (recipe.containsKey("TargetFramework")) {
			targetFramework = recipe["TargetFramework"]
		} else {
			Fiber.abort("Missing required Target Framework")
		}

		build["TargetFramework"] = targetFramework
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
