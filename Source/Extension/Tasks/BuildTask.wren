// <copyright file="BuildTask.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

class BuildTask is SoupExtension
{
	/// <summary>
	/// Get the run before list
	/// </summary>
	static runBefore { [] }

	/// <summary>
	/// Get the run after list
	/// </summary>
	static runAfter { [] }

	BuildTask() :
		this(new Dictionary<string, Func<IValueTable, ICompiler>>())
	{
		// Register default compilers
		// TODO: Fix up compiler names for different languages
		this.compilerFactory.add("MSVC", (IValueTable activeState) {
		{
			var clToolPath = Path.new(activeState["Roslyn.CscToolPath"].AsString())
			return new Compiler.Roslyn.Compiler(clToolPath)
		})
	}

	static evaluate() {
		var activeState = Soup.ActiveState
		var sharedState = Soup.SharedState

		var buildTable = activeState["Build"].AsTable()
		var parametersTable = activeState["Parameters"].AsTable()

		var arguments = new BuildArguments()
		arguments.TargetArchitecture = parametersTable["Architecture"].AsString()
		arguments.TargetName = buildTable["TargetName"].AsString()
		arguments.TargetType = (BuildTargetType)buildTable["TargetType"].AsInteger()
		arguments.SourceRootDirectory = Path.new(buildTable["SourceRootDirectory"].AsString())
		arguments.TargetRootDirectory = Path.new(buildTable["TargetRootDirectory"].AsString())
		arguments.ObjectDirectory = Path.new(buildTable["ObjectDirectory"].AsString())
		arguments.BinaryDirectory = Path.new(buildTable["BinaryDirectory"].AsString())

		if (buildTable.TryGetValue("Source", out var sourceValue)) {
			arguments.SourceFiles = sourceValue.AsList().Select(value { Path.new(value.AsString())).ToList()
		}

		if (buildTable.TryGetValue("LibraryPaths", out var libraryPathsValue)) {
			arguments.LibraryPaths = libraryPathsValue.AsList().Select(value { Path.new(value.AsString())).ToList()
		}

		if (buildTable.TryGetValue("PreprocessorDefinitions", out var preprocessorDefinitionsValue)) {
			arguments.PreprocessorDefinitions = preprocessorDefinitionsValue.AsList().Select(value { value.AsString()).ToList()
		}

		if (buildTable.TryGetValue("OptimizationLevel", out var optimizationLevelValue)) {
			arguments.OptimizationLevel = (BuildOptimizationLevel)
				optimizationLevelValue.AsInteger()
		} else {
			arguments.OptimizationLevel = BuildOptimizationLevel.None
		}

		if (buildTable.TryGetValue("GenerateSourceDebugInfo", out var generateSourceDebugInfoValue)) {
			arguments.GenerateSourceDebugInfo = generateSourceDebugInfoValue.AsBoolean()
		} else {
			arguments.GenerateSourceDebugInfo = false
		}

		if (buildTable.TryGetValue("NullableState", out var nullableValue)) {
			arguments.NullableState = (BuildNullableState)nullableValue.AsInteger()
		} else {
			arguments.NullableState = BuildNullableState.Enabled
		}

		// Load the runtime dependencies
		if (buildTable.TryGetValue("RuntimeDependencies", out var runtimeDependenciesValue)) {
			arguments.RuntimeDependencies = MakeUnique(
				runtimeDependenciesValue.AsList().Select(value { Path.new(value.AsString())))
		}

		// Load the link dependencies
		if (buildTable.TryGetValue("LinkDependencies", out var linkDependenciesValue)) {
			arguments.LinkDependencies = MakeUnique(
				linkDependenciesValue.AsList().Select(value { Path.new(value.AsString())))
		}

		// Load the list of disabled warnings
		if (buildTable.TryGetValue("EnableWarningsAsErrors", out var enableWarningsAsErrorsValue)) {
			arguments.EnableWarningsAsErrors = enableWarningsAsErrorsValue.AsBoolean()
		} else {
			arguments.GenerateSourceDebugInfo = false
		}

		// Load the list of disabled warnings
		if (buildTable.TryGetValue("DisabledWarnings", out var disabledWarningsValue)) {
			arguments.DisabledWarnings = disabledWarningsValue.AsList().Select(value { value.AsString()).ToList()
		}

		// Check for any custom compiler flags
		if (buildTable.TryGetValue("CustomCompilerProperties", out var customCompilerPropertiesValue)) {
			arguments.CustomProperties = customCompilerPropertiesValue.AsList().Select(value { value.AsString()).ToList()
		}

		// Initialize the compiler to use
		var compilerName = parametersTable["Compiler"].AsString()
		if (!this.compilerFactory.TryGetValue(compilerName, out var compileFactory)) {
			this.buildState.LogTrace(TraceLevel.Error, "Unknown compiler: " + compilerName)
			Fiber.abort()
		}

		var compiler = compileFactory(activeState)

		var buildEngine = BuildEngine.new(compiler)
		var buildResult = buildEngine.Execute(this.buildState, arguments)

		// Pass along internal state for other stages to gain access
		buildTable.EnsureValueList(this.factory, "InternalLinkDependencies").SetAll(this.factory, buildResult.InternalLinkDependencies)

		// Always pass along required input to shared build tasks
		var sharedBuildTable = sharedState.EnsureValueTable(this.factory, "Build")
		sharedBuildTable.EnsureValueList(this.factory, "RuntimeDependencies").SetAll(this.factory, buildResult.RuntimeDependencies)
		sharedBuildTable.EnsureValueList(this.factory, "LinkDependencies").SetAll(this.factory, buildResult.LinkDependencies)

		if (!buildResult.TargetFile.IsEmpty)
		{
			sharedBuildTable["TargetFile"] = this.factory.Create(buildResult.TargetFile.ToString())
			sharedBuildTable["RunExecutable"] = this.factory.Create("C:/Program Files/dotnet/dotnet.exe")
			
			sharedBuildTable.EnsureValueList(this.factory, "RunArguments").SetAll(this.factory, [ { buildResult.TargetFile.ToString() })
		}

		// Register the build operations
		for (operation in buildResult.BuildOperations) {
			this.buildState.CreateOperation(operation)
		}

		this.buildState.LogTrace(TraceLevel.Information, "Build Generate Done")
	}

	static MakeUnique(collection) {
		var valueSet = new HashSet<string>()
		for (value in collection) {
			valueSet.add(value.ToString())
		}

		return valueSet.Select(value { Path.new(value)).ToList()
	}
}
