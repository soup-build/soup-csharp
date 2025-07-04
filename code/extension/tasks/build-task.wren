// <copyright file="build-task.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

import "soup" for Soup, SoupTask
import "Soup|Build.Utils:./path" for Path
import "Soup|Build.Utils:./set" for Set
import "Soup|Build.Utils:./list-extensions" for ListExtensions
import "Soup|Build.Utils:./map-extensions" for MapExtensions
import "Soup|CSharp.Compiler:./build-options" for BuildOptions, BuildOptimizationLevel, BuildNullableState
import "Soup|CSharp.Compiler:./build-engine" for BuildEngine
import "Soup|CSharp.Compiler.Roslyn:./roslyn-compiler" for RoslynCompiler

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
		BuildTask.registerCompiler("Roslyn", BuildTask.createRoslynCompiler)

		var activeState = Soup.activeState
		var sharedState = Soup.sharedState

		var buildTable = activeState["Build"]

		var dotnet = activeState["DotNet"]
		var dotnetPath = Path.new(dotnet["ExecutablePath"])

		var options = BuildOptions.new()
		options.TargetArchitecture = buildTable["Architecture"]
		options.TargetFramework = buildTable["TargetFramework"]
		options.TargetName = buildTable["TargetName"]
		options.TargetType = buildTable["TargetType"]
		options.SourceRootDirectory = Path.new(buildTable["SourceRootDirectory"])
		options.TargetRootDirectory = Path.new(buildTable["TargetRootDirectory"])
		options.ObjectDirectory = Path.new(buildTable["ObjectDirectory"])
		options.BinaryDirectory = Path.new(buildTable["BinaryDirectory"])

		if (buildTable.containsKey("Source")) {
			options.SourceFiles = ListExtensions.ConvertToPathList(buildTable["Source"])
		}

		if (buildTable.containsKey("LinkLibraries")) {
			options.LinkDependencies = BuildTask.MakeUnique(ListExtensions.ConvertToPathList(buildTable["LinkLibraries"]))
		}

		if (buildTable.containsKey("LibraryPaths")) {
			options.LibraryPaths = ListExtensions.ConvertToPathList(buildTable["LibraryPaths"])
		}

		if (buildTable.containsKey("DefineConstants")) {
			options.DefineConstants = buildTable["DefineConstants"]
		}

		if (buildTable.containsKey("OptimizationLevel")) {
			options.OptimizationLevel = buildTable["OptimizationLevel"]
		} else {
			options.OptimizationLevel = BuildOptimizationLevel.None
		}

		if (buildTable.containsKey("GenerateSourceDebugInfo")) {
			options.GenerateSourceDebugInfo = buildTable["GenerateSourceDebugInfo"]
		} else {
			options.GenerateSourceDebugInfo = false
		}

		if (buildTable.containsKey("NullableState")) {
			options.NullableState = buildTable["NullableState"]
		} else {
			options.NullableState = BuildNullableState.Enabled
		}

		// Load the runtime dependencies
		if (buildTable.containsKey("RuntimeDependencies")) {
			options.RuntimeDependencies = BuildTask.MakeUnique(
				ListExtensions.ConvertToPathList(buildTable["RuntimeDependencies"]))
		}

		// Load the link dependencies
		if (buildTable.containsKey("LinkDependencies")) {
			options.LinkDependencies = BuildTask.CombineUnique(
				options.LinkDependencies,
				ListExtensions.ConvertToPathList(buildTable["LinkDependencies"]))
		}

		// Load the analyzers
		if (buildTable.containsKey("Analyzers")) {
			options.Analyzers = BuildTask.CombineUnique(
				options.Analyzers,
				ListExtensions.ConvertToPathList(buildTable["Analyzers"]))
		}

		// Load the list of disabled warnings
		if (buildTable.containsKey("AllowUnsafeBlocks")) {
			options.AllowUnsafeBlocks = buildTable["AllowUnsafeBlocks"]
		} else {
			options.AllowUnsafeBlocks = false
		}

		// Load the list of disabled warnings
		if (buildTable.containsKey("TreatWarningsAsErrors")) {
			options.TreatWarningsAsErrors = buildTable["TreatWarningsAsErrors"]
		} else {
			options.TreatWarningsAsErrors = false
		}

		// Load the list of disabled warnings
		if (buildTable.containsKey("DisabledWarnings")) {
			options.DisabledWarnings = buildTable["DisabledWarnings"]
		}

		// Check for any custom compiler flags
		if (buildTable.containsKey("CustomCompilerProperties")) {
			options.CustomProperties = buildTable["CustomCompilerProperties"]
		}

		// Initialize the compiler to use
		var compilerName = buildTable["Compiler"]
		Soup.info("Using Compiler: %(compilerName)")
		if (!__compilerFactory.containsKey(compilerName)) {
			Fiber.abort("Unknown compiler: %(compilerName)")
		}

		var compiler = __compilerFactory[compilerName].call(activeState)

		var buildEngine = BuildEngine.new(compiler)
		var buildResult = buildEngine.Execute(options)

		// Pass along internal state for other stages to gain access
		buildTable["InternalLinkDependencies"] = ListExtensions.ConvertFromPathList(buildResult.InternalLinkDependencies)

		// Always pass along required input to shared build tasks
		var sharedBuildTable = MapExtensions.EnsureTable(sharedState, "Build")
		sharedBuildTable["RuntimeDependencies"] = ListExtensions.ConvertFromPathList(buildResult.RuntimeDependencies)
		sharedBuildTable["LinkDependencies"] = ListExtensions.ConvertFromPathList(buildResult.LinkDependencies)

		if (!(buildResult.TargetFile is Null)) {
			sharedBuildTable["TargetFile"] = buildResult.TargetFile.toString
			sharedBuildTable["RunExecutable"] = dotnetPath.toString
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
			var dotnet = activeState["DotNet"]
			var roslyn = activeState["Roslyn"]

			var dotnetPath = Path.new(dotnet["ExecutablePath"])
			var cscToolPath = Path.new(roslyn["CscToolPath"])
			return RoslynCompiler.new(
				dotnetPath,
				cscToolPath)
		}
	}

	static CombineUnique(collection1, collection2) {
		var valueSet = Set.new()
		for (value in collection1) {
			valueSet.add(value.toString)
		}
		for (value in collection2) {
			valueSet.add(value.toString)
		}

		return ListExtensions.ConvertToPathList(valueSet.list)
	}

	static MakeUnique(collection) {
		var valueSet = Set.new()
		for (value in collection) {
			valueSet.add(value.toString)
		}

		return ListExtensions.ConvertToPathList(valueSet.list)
	}
}
