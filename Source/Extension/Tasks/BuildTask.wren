// <copyright file="BuildTask.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

import "soup" for Soup, SoupTask
import "../../Compiler/Core/BuildArguments" for BuildArguments, BuildOptimizationLevel, BuildNullableState
import "../../Compiler/Core/BuildEngine" for BuildEngine
import "../../Compiler/Roslyn/RoslynCompiler" for RoslynCompiler
import "../../Utils/ListExtensions" for ListExtensions
import "../../Utils/MapExtensions" for MapExtensions
import "../../Utils/Path" for Path
import "../../Utils/Set" for Set

class BuildTask is SoupTask {
	/// <summary>
	/// Get the run before list
	/// </summary>
	static runBefore { [] }

	/// <summary>
	/// Get the run after list
	/// </summary>
	static runAfter { [] }

	static registerCompiler(name, factory) {
		if (__compilerFactory is Null) __compilerFactory = {}
		__compilerFactory[name] = factory
	}

	static evaluate() {
		// Register default compilers
		BuildTask.registerCompiler("MSVC", BuildTask.createRoslynCompiler)

		var globalState = Soup.globalState
		var activeState = Soup.activeState
		var sharedState = Soup.sharedState

		var buildTable = activeState["Build"]
		var parametersTable = globalState["Parameters"]

		var arguments = BuildArguments.new()
		arguments.TargetArchitecture = parametersTable["Architecture"]
		arguments.TargetName = buildTable["TargetName"]
		arguments.TargetType = buildTable["TargetType"]
		arguments.SourceRootDirectory = Path.new(buildTable["SourceRootDirectory"])
		arguments.TargetRootDirectory = Path.new(buildTable["TargetRootDirectory"])
		arguments.ObjectDirectory = Path.new(buildTable["ObjectDirectory"])
		arguments.BinaryDirectory = Path.new(buildTable["BinaryDirectory"])

		if (buildTable.containsKey("Source")) {
			arguments.SourceFiles = ListExtensions.ConvertToPathList(buildTable["Source"])
		}

		if (buildTable.containsKey("LibraryPaths")) {
			arguments.LibraryPaths = ListExtensions.ConvertToPathList(buildTable["LibraryPaths"])
		}

		if (buildTable.containsKey("PreprocessorDefinitions")) {
			arguments.PreprocessorDefinitions = buildTable["PreprocessorDefinitions"]
		}

		if (buildTable.containsKey("OptimizationLevel")) {
			arguments.OptimizationLevel = buildTable["OptimizationLevel"]
		} else {
			arguments.OptimizationLevel = BuildOptimizationLevel.None
		}

		if (buildTable.containsKey("GenerateSourceDebugInfo")) {
			arguments.GenerateSourceDebugInfo = buildTable["GenerateSourceDebugInfo"]
		} else {
			arguments.GenerateSourceDebugInfo = false
		}

		if (buildTable.containsKey("NullableState")) {
			arguments.NullableState = buildTable["NullableState"]
		} else {
			arguments.NullableState = BuildNullableState.Enabled
		}

		// Load the runtime dependencies
		if (buildTable.containsKey("RuntimeDependencies")) {
			arguments.RuntimeDependencies = BuildTask.MakeUnique(
				ListExtensions.ConvertToPathList(buildTable["RuntimeDependencies"]))
		}

		// Load the link dependencies
		if (buildTable.containsKey("LinkDependencies")) {
			arguments.LinkDependencies = BuildTask.MakeUnique(
				ListExtensions.ConvertToPathList(buildTable["LinkDependencies"]))
		}

		// Load the list of disabled warnings
		if (buildTable.containsKey("EnableWarningsAsErrors")) {
			arguments.EnableWarningsAsErrors = buildTable["EnableWarningsAsErrors"]
		} else {
			arguments.GenerateSourceDebugInfo = false
		}

		// Load the list of disabled warnings
		if (buildTable.containsKey("DisabledWarnings")) {
			arguments.DisabledWarnings = buildTable["DisabledWarnings"]
		}

		// Check for any custom compiler flags
		if (buildTable.containsKey("CustomCompilerProperties")) {
			arguments.CustomProperties = buildTable["CustomCompilerProperties"]
		}

		// Initialize the compiler to use
		var compilerName = parametersTable["Compiler"]
		if (!__compilerFactory.containsKey(compilerName)) {
			Fiber.abort("Unknown compiler: %(compilerName)")
		}

		var compiler = __compilerFactory[compilerName].call(activeState)

		var buildEngine = BuildEngine.new(compiler)
		var buildResult = buildEngine.Execute(arguments)

		// Pass along internal state for other stages to gain access
		buildTable["InternalLinkDependencies"] = buildResult.InternalLinkDependencies

		// Always pass along required input to shared build tasks
		var sharedBuildTable = MapExtensions.EnsureTable(sharedState, "Build")
		sharedBuildTable["RuntimeDependencies"] = buildResult.RuntimeDependencies
		sharedBuildTable["LinkDependencies"] = buildResult.LinkDependencies

		if (!buildResult.TargetFile is Null) {
			sharedBuildTable["TargetFile"] = buildResult.TargetFile.toString
			sharedBuildTable["RunExecutable"] = "C:/Program Files/dotnet/dotnet.exe"

			sharedBuildTable["RunArguments"] = [ buildResult.TargetFile.toString ]
		}

		// Register the build operations
		for (operation in buildResult.BuildOperations) {
			Soup.createOperation(
				operation.Title,
				operation.Executable.toString,
				operation.Arguments,
				operation.WorkingDirectory.toString,
				ListExtensions.ConvertFromPathList(operation.DeclaredInput),
				ListExtensions.ConvertFromPathList(operation.DeclaredOutput))
		}

		Soup.info("Build Generate Done")
	}

	static createRoslynCompiler {
		return Fn.new { |activeState|
			var clToolPath = Path.new(activeState["Roslyn.CscToolPath"])
			return RoslynCompiler.new(clToolPath)
		}
	}

	static MakeUnique(collection) {
		var valueSet = Set.new()
		for (value in collection) {
			valueSet.add(value.toString)
		}

		return ListExtensions.ConvertToPathList(valueSet.list)
	}
}
