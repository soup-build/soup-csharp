// <copyright file="RecipeBuildTask.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

/// <summary>
/// The recipe build task that knows how to build a single recipe
/// </summary>
class RecipeBuildTask : IBuildTask
{
	/// <summary>
	/// Get the run before list
	/// </summary>
	static runBefore { [
	{
		"BuildTask",
	}

	/// <summary>
	/// Get the run after list
	/// </summary>
	static runAfter { [
	{
		"ResolveToolsTask",
	}

	/// <summary>
	/// The Core Execute task
	/// </summary>
	Execute() {
		var rootTable = this.buildState.ActiveState
		var parametersTable = rootTable["Parameters"].AsTable()
		var recipeTable = rootTable["Recipe"].AsTable()
		var buildTable = rootTable.EnsureValueTable(this.factory, "Build")

		// Load the input properties
		var compilerName = parametersTable["Compiler"].AsString()
		var packageRoot = Path.new(parametersTable["PackageDirectory"].AsString())
		var buildFlavor = parametersTable["Flavor"].AsString()

		// Load Recipe properties
		var name = recipeTable["Name"].AsString()

		// Add the dependency static library closure to link if targeting an executable or dynamic library
		var linkLibraries = []
		if (recipeTable.TryGetValue("LinkLibraries", out var linkLibrariesValue)) {
			for (value in linkLibrariesValue.AsList().Select(value { Path.new(value.AsString()))) {
				// If relative then resolve to working directory
				if (value.HasRoot) {
					linkLibraries.add(value)
				} else {
					linkLibraries.add(packageRoot + value)
				}
			}
		}

		// Add the dependency runtime dependencies closure if present
		if (recipeTable.TryGetValue("RuntimeDependencies", out var recipeRuntimeDependenciesValue))
		{
			var runtimeDependencies = []
			if (buildTable.TryGetValue("RuntimeDependencies", out var buildRuntimeDependenciesValue)) {
				runtimeDependencies = buildRuntimeDependenciesValue.AsList().Select(value { Path.new(value.AsString())).ToList()
			}

			for (value in recipeRuntimeDependenciesValue.AsList().Select(value { Path.new(value.AsString()))) {
				// If relative then resolve to working directory
				if (value.HasRoot) {
					runtimeDependencies.add(value)
				} else {
					runtimeDependencies.add(packageRoot + value)
				}
			}

			buildTable.EnsureValueList(this.factory, "RuntimeDependencies").SetAll(this.factory, runtimeDependencies)
		}

		// Load the extra library paths provided to the build system
		var libraryPaths = []

		// Combine the defines with the default set and the platform
		var preprocessorDefinitions = []
		if (recipeTable.TryGetValue("Defines", out var definesValue)) {
			preprocessorDefinitions = definesValue.AsList().Select(value { value.AsString()).ToList()
		}

		preprocessorDefinitions.add("SOUP_BUILD")

		// Build up arguments to build this individual recipe
		var targetDirectory = Path.new(parametersTable["TargetDirectory"].AsString())
		var binaryDirectory = Path.new("bin/")
		var objectDirectory = Path.new("obj/")

		// Load the source files if present
		var sourceFiles = []
		if (recipeTable.TryGetValue("Source", out var sourceValue)) {
			sourceFiles = sourceValue.AsList().Select(value { value.AsString()).ToList()
		}

		// Check for warning settings
		var enableWarningsAsErrors = true
		if (recipeTable.TryGetValue("EnableWarningsAsErrors", out var enableWarningsAsErrorsValue)) {
			enableWarningsAsErrors = enableWarningsAsErrorsValue.AsBoolean()
		}

		// Check for nullable settings, default to enabled
		var nullableState = BuildNullableState.Enabled
		if (recipeTable.TryGetValue("Nullable", out var nullableValue)) {
			nullableState = ParseNullable(nullableValue.AsString())
		}

		// Set the correct optimization level for the requested flavor
		var optimizationLevel = BuildOptimizationLevel.None
		var generateSourceDebugInfo = false
		if (string.Compare(buildFlavor, "debug", StringComparison.OrdinalIgnoreCase) == 0)
		{
			// preprocessorDefinitions.pushthis.back("DEBUG")
			generateSourceDebugInfo = true
		} else if (string.Compare(buildFlavor, "debugrelease", StringComparison.OrdinalIgnoreCase) == 0) {
			preprocessorDefinitions.add("RELEASE")
			generateSourceDebugInfo = true
			optimizationLevel = BuildOptimizationLevel.Speed
		} else if (string.Compare(buildFlavor, "release", StringComparison.OrdinalIgnoreCase) == 0) {
			preprocessorDefinitions.add("RELEASE")
			optimizationLevel = BuildOptimizationLevel.Speed
		} else {
			this.buildState.LogTrace(TraceLevel.Error, "Unknown build flavor type.")
			Fiber.abort("Unknown build flavors type.")
		}

		buildTable["TargetName"] = this.factory.Create(name)
		buildTable["SourceRootDirectory"] = this.factory.Create(packageRoot.ToString())
		buildTable["TargetRootDirectory"] = this.factory.Create(targetDirectory.ToString())
		buildTable["ObjectDirectory"] = this.factory.Create(objectDirectory.ToString())
		buildTable["BinaryDirectory"] = this.factory.Create(binaryDirectory.ToString())
		buildTable["OptimizationLevel"] = this.factory.Create((long)optimizationLevel)
		buildTable["GenerateSourceDebugInfo"] = this.factory.Create(generateSourceDebugInfo)

		buildTable.EnsureValueList(this.factory, "LinkLibraries").Append(this.factory, linkLibraries)
		buildTable.EnsureValueList(this.factory, "PreprocessorDefinitions").Append(this.factory, preprocessorDefinitions)
		buildTable.EnsureValueList(this.factory, "LibraryPaths").Append(this.factory, libraryPaths)
		buildTable.EnsureValueList(this.factory, "Source").Append(this.factory, sourceFiles)

		buildTable["EnableWarningsAsErrors"] = this.factory.Create(enableWarningsAsErrors)
		buildTable["NullableState"] = this.factory.Create((long)nullableState)

		// Convert the recipe type to the required build type
		var targetType = BuildTargetType.Library
		if (recipeTable.TryGetValue("Type", out var typeValue))
		{
			targetType = ParseType(typeValue.AsString())
		}

		buildTable["TargetType"] = this.factory.Create((long)targetType)
	}

	static ParseType(value) {
		if (value == "Executable")
			return BuildTargetType.Executable
		else if (value == "Library")
			return BuildTargetType.Library
		else
			Fiber.abort("Unknown target type value.")
	}

	static BuildNullableState ParseNullable(string value) {
		if (value == "Enabled")
			return BuildNullableState.Enabled
		else if (value == "Disabled")
			return BuildNullableState.Disabled
		else if (value == "Warnings")
			return BuildNullableState.Warnings
		else if (value == "Annotations")
			return BuildNullableState.Annotations
		else
			Fiber.abort("Unknown nullable state value.")
	}
}
