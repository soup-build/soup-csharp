// <copyright file="BuildEngineUnitTests.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

import "soup-test" for SoupTest
import "Soup.CSharp.Compiler:./BuildArguments" for BuildArguments, BuildNullableState, BuildOptimizationLevel, BuildTargetType
import "Soup.CSharp.Compiler:./CompileArguments" for CompileArguments, LinkTarget, NullableState
import "Soup.CSharp.Compiler:./BuildEngine" for BuildEngine
import "Soup.CSharp.Compiler:./MockCompiler" for MockCompiler
import "Soup.Build.Utils:./BuildOperation" for BuildOperation
import "Soup.Build.Utils:./Path" for Path
import "../../Test/Assert" for Assert

class BuildEngineUnitTests {
	construct new() {
	}

	RunTests() {
		System.print("BuildEngineUnitTests.Initialize_Success")
		this.Initialize_Success()
		System.print("BuildEngineUnitTests.Build_Executable")
		this.Build_Executable()
		System.print("BuildEngineUnitTests.Build_Library_MultipleFiles")
		this.Build_Library_MultipleFiles()
	}

	// [Fact]
	Initialize_Success() {
		var compiler = MockCompiler.new()
		var uut = BuildEngine.new(compiler)
	}

	// [Fact]
	Build_Executable() {
		SoupTest.initialize()
		var globalState = SoupTest.globalState

		// Setup dependencies table
		var dependenciesTable = {}
		globalState["Dependencies"] = dependenciesTable
		dependenciesTable["Tool"] = {
			"mkdir": {
				"SharedState": {
					"Build": {
						"RunExecutable": "/TARGET/mkdir.exe"
					}
				}
			}
		}

		// Register the mock compiler
		var compiler = MockCompiler.new()

		// Setup the build arguments
		var arguments = BuildArguments.new()
		arguments.TargetName = "Program"
		arguments.TargetType = BuildTargetType.Executable
		arguments.SourceRootDirectory = Path.new("C:/source/")
		arguments.TargetRootDirectory = Path.new("C:/target/")
		arguments.ObjectDirectory = Path.new("obj/")
		arguments.BinaryDirectory = Path.new("bin/")
		arguments.SourceFiles = [
			Path.new("TestFile.cs"),
		]
		arguments.OptimizationLevel = BuildOptimizationLevel.None
		arguments.LinkDependencies = [
			Path.new("../Other/bin/OtherModule1.mock.a"),
			Path.new("../OtherModule2.mock.a"),
		]
		arguments.NullableState = BuildNullableState.Enabled

		var uut = BuildEngine.new(compiler)
		var result = uut.Execute(arguments)

		// // Verify expected logs
		Assert.ListEqual(
			[],
			SoupTest.logs)

		var expectedCompileArguments = CompileArguments.new()
		expectedCompileArguments.Target = Path.new("./bin/Program.mock.dll")
		expectedCompileArguments.ReferenceTarget = Path.new("./bin/ref/Program.mock.dll")
		expectedCompileArguments.TargetType = LinkTarget.Executable
		expectedCompileArguments.ObjectDirectory = Path.new("obj/")
		expectedCompileArguments.SourceRootDirectory = Path.new("C:/source/")
		expectedCompileArguments.TargetRootDirectory = Path.new("C:/target/")
		expectedCompileArguments.SourceFiles = [
			Path.new("TestFile.cs"),
		]
		expectedCompileArguments.ReferenceLibraries = [
			Path.new("../Other/bin/OtherModule1.mock.a"),
			Path.new("../OtherModule2.mock.a"),
		]
		expectedCompileArguments.NullableState = NullableState.Enabled

		// Verify expected compiler calls
		var val = compiler.GetCompileRequests()[0]
		var areEqual = val == expectedCompileArguments
		var areEqual2 = val.ObjectDirectory == expectedCompileArguments.ObjectDirectory
		Assert.ListEqual(
			[
				expectedCompileArguments,
			],
			compiler.GetCompileRequests())

		var expectedBuildOperations = [
			BuildOperation.new(
				"MakeDir [./obj/]",
				Path.new("C:/target/"),
				Path.new("/TARGET/mkdir.exe"),
				[
					"./obj/",
				],
				[],
				[
					Path.new("./obj/"),
				]),
			BuildOperation.new(
				"MakeDir [./bin/]",
				Path.new("C:/target/"),
				Path.new("/TARGET/mkdir.exe"),
				[
					"./bin/",
				],
				[],
				[
					Path.new("./bin/"),
				]),
			BuildOperation.new(
				"MakeDir [./bin/ref/]",
				Path.new("C:/target/"),
				Path.new("/TARGET/mkdir.exe"),
				[
					"./bin/ref/",
				],
				[],
				[
					Path.new("./bin/ref/"),
				]),
			BuildOperation.new(
				"MockCompile: 1",
				Path.new("MockWorkingDirectory"),
				Path.new("MockCompiler.exe"),
				[
					"Arguments",
				],
				[
					Path.new("./InputFile.in"),
				],
				[
					Path.new("./OutputFile.out"),
				]),
			BuildOperation.new(
				"WriteFile [./bin/Program.runtimeconfig.json]",
				Path.new("C:/target/"),
				Path.new("./writefile.exe"),
				[
					"./bin/Program.runtimeconfig.json",
					"{
	\"runtimeOptions\": {
		\"tfm\": \"net6.0\",
		\"framework\": {
			\"name\": \"Microsoft.NETCore.App\",
			\"version\": \"6.0.0\"
		},
		\"configProperties\": {
			\"System.Reflection.Metadata.MetadataUpdater.IsSupported\": false
		}
	}
}",
				],
				[],
				[
					Path.new("./bin/Program.runtimeconfig.json"),
				]),
		]

		Assert.ListEqual(
			expectedBuildOperations,
			result.BuildOperations)

		Assert.ListEqual(
			[],
			result.LinkDependencies)

		Assert.ListEqual(
			[
				Path.new("C:/target/bin/Program.mock.dll"),
			],
			result.RuntimeDependencies)
	}

	// [Fact]
	Build_Library_MultipleFiles() {
		// Register the mock compiler
		var compiler = MockCompiler.new()

		// Setup the build arguments
		var arguments = BuildArguments.new()
		arguments.TargetName = "Library"
		arguments.TargetType = BuildTargetType.Library
		arguments.SourceRootDirectory = Path.new("C:/source/")
		arguments.TargetRootDirectory = Path.new("C:/target/")
		arguments.ObjectDirectory = Path.new("obj/")
		arguments.BinaryDirectory = Path.new("bin/")
		arguments.SourceFiles = [
			Path.new("TestFile1.cs"),
			Path.new("TestFile2.cs"),
			Path.new("TestFile3.cs"),
		]
		arguments.OptimizationLevel = BuildOptimizationLevel.Size
		arguments.LinkDependencies = [
			Path.new("../Other/bin/OtherModule1.mock.a"),
			Path.new("../OtherModule2.mock.a"),
		]
		arguments.NullableState = BuildNullableState.Disabled

		var uut = BuildEngine.new(compiler)
		var result = uut.Execute(arguments)

		// // Verify expected logs
		Assert.ListEqual(
			[],
			SoupTest.logs)

		// Setup the shared arguments
		var expectedCompileArguments = CompileArguments.new()
		expectedCompileArguments.Target = Path.new("./bin/Library.mock.dll")
		expectedCompileArguments.TargetType = LinkTarget.Library
		expectedCompileArguments.ReferenceTarget = Path.new("./bin/ref/Library.mock.dll")
		expectedCompileArguments.SourceRootDirectory = Path.new("C:/source/")
		expectedCompileArguments.TargetRootDirectory = Path.new("C:/target/")
		expectedCompileArguments.ObjectDirectory = Path.new("obj/")
		expectedCompileArguments.SourceFiles = [
			Path.new("TestFile1.cs"),
			Path.new("TestFile2.cs"),
			Path.new("TestFile3.cs"),
		]
		expectedCompileArguments.ReferenceLibraries = [
			Path.new("../Other/bin/OtherModule1.mock.a"),
			Path.new("../OtherModule2.mock.a"),
		]
		expectedCompileArguments.NullableState = NullableState.Disabled

		// Verify expected compiler calls
		Assert.ListEqual(
			[
				expectedCompileArguments,
			],
			compiler.GetCompileRequests())

		// Verify build state
		var expectedBuildOperations = [
			BuildOperation.new(
				"MakeDir [./obj/]",
				Path.new("C:/target/"),
				Path.new("/TARGET/mkdir.exe"),
				[
					"./obj/",
				],
				[],
				[
					Path.new("./obj/"),
				]),
			BuildOperation.new(
				"MakeDir [./bin/]",
				Path.new("C:/target/"),
				Path.new("/TARGET/mkdir.exe"),
				[
					"./bin/",
				],
				[],
				[
					Path.new("./bin/"),
				]),
			BuildOperation.new(
				"MakeDir [./bin/ref/]",
				Path.new("C:/target/"),
				Path.new("/TARGET/mkdir.exe"),
				[
					"./bin/ref/",
				],
				[],
				[
					Path.new("./bin/ref/"),
				]),
			BuildOperation.new(
				"MockCompile: 1",
				Path.new("MockWorkingDirectory"),
				Path.new("MockCompiler.exe"),
				[
					"Arguments",
				],
				[
					Path.new("InputFile.in"),
				],
				[
					Path.new("OutputFile.out"),
				]),
		]

		Assert.ListEqual(
			expectedBuildOperations,
			result.BuildOperations)

		Assert.ListEqual(
			[
				Path.new("C:/target/bin/ref/Library.mock.dll"),
			],
			result.LinkDependencies)

		Assert.ListEqual(
			[
				Path.new("C:/target/bin/Library.mock.dll"),
			],
			result.RuntimeDependencies)

		Assert.Equal(
			Path.new("C:/target/bin/Library.mock.dll"),
			result.TargetFile)
	}
}