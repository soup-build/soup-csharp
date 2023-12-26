// <copyright file="BuildTaskUnitTests.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

import "soup-test" for SoupTest, SoupTestOperation
import "../../Extension/Tasks/BuildTask" for BuildTask
import "mwasplund|Soup.CSharp.Compiler:./MockCompiler" for MockCompiler
import "mwasplund|Soup.CSharp.Compiler:./BuildArguments" for BuildOptimizationLevel, BuildTargetType
import "mwasplund|Soup.CSharp.Compiler:./CompileArguments" for CompileArguments, LinkTarget, NullableState
import "mwasplund|Soup.Build.Utils:./Path" for Path
import "../../Test/Assert" for Assert

class BuildTaskUnitTests {
	construct new() {
	}

	RunTests() {
		System.print("BuildTaskUnitTests.Build_Executable")
		this.Build_Executable()
		System.print("BuildTaskUnitTests.Build_Library_MultipleFiles")
		this.Build_Library_MultipleFiles()
	}

	// [Fact]
	Build_Executable() {
		// Setup the input build state
		SoupTest.initialize()
		var activeState = SoupTest.activeState
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

		// Setup build table
		var buildTable = {}
		activeState["Build"] = buildTable
		buildTable["Architecture"] = "x64"
		buildTable["Compiler"] = "MOCK"
		buildTable["TargetName"] = "Program"
		buildTable["TargetType"] = BuildTargetType.Executable
		buildTable["SourceRootDirectory"] = "C:/source/"
		buildTable["TargetRootDirectory"] = "C:/target/"
		buildTable["ObjectDirectory"] = "obj/"
		buildTable["BinaryDirectory"] = "bin/"
		buildTable["Source"] = [
			"TestFile.cs",
		]

		// Setup dotnet table
		var dotnetTable = {}
		activeState["DotNet"] = dotnetTable
		dotnetTable["ExecutablePath"] = "C:/bin/mock.dotnet.exe"

		// Register the mock compiler
		var compiler = MockCompiler.new()
		BuildTask.registerCompiler("MOCK", Fn.new { |activeState| compiler })

		BuildTask.evaluate()

		// Verify expected logs
		Assert.ListEqual(
			[
				"INFO: Using Compiler: MOCK",
				"INFO: Build Generate Done",
			],
			SoupTest.logs)

		var expectedCompileArguments = CompileArguments.new()
		expectedCompileArguments.Target = Path.new("./bin/Program.mock.dll")
		expectedCompileArguments.ReferenceTarget = Path.new("./bin/ref/Program.mock.dll")
		expectedCompileArguments.TargetType = LinkTarget.Executable
		expectedCompileArguments.SourceRootDirectory = Path.new("C:/source/")
		expectedCompileArguments.TargetRootDirectory = Path.new("C:/target/")
		expectedCompileArguments.ObjectDirectory = Path.new("obj/")
		expectedCompileArguments.SourceFiles = [
			Path.new("TestFile.cs")
		]
		expectedCompileArguments.NullableState = NullableState.Enabled

		// Verify expected compiler calls
		Assert.ListEqual(
			[
				expectedCompileArguments,
			],
			compiler.GetCompileRequests())

		// Verify build state
		var expectedBuildOperations = [
			SoupTestOperation.new(
				"MakeDir [./obj/]",
				Path.new("/TARGET/mkdir.exe"),
				[
					"./obj/",
				],
				Path.new("C:/target/"),
				[],
				[
					Path.new("./obj/"),
				]),
			SoupTestOperation.new(
				"MakeDir [./bin/]",
				Path.new("/TARGET/mkdir.exe"),
				[
					"./bin/",
				],
				Path.new("C:/target/"),
				[],
				[
					Path.new("./bin/"),
				]),
			SoupTestOperation.new(
				"MakeDir [./bin/ref/]",
				Path.new("/TARGET/mkdir.exe"),
				[
					"./bin/ref/",
				],
				Path.new("C:/target/"),
				[],
				[
					Path.new("./bin/ref/"),
				]),
			SoupTestOperation.new(
				"MockCompile: 1",
				Path.new("MockCompiler.exe"),
				[
					"Arguments",
				],
				Path.new("MockWorkingDirectory"),
				[
					Path.new("./InputFile.in"),
				],
				[
					Path.new("./OutputFile.out"),
				]),
			SoupTestOperation.new(
				"WriteFile [./bin/Program.runtimeconfig.json]",
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
				Path.new("C:/target/"),
				[],
				[
					Path.new("./bin/Program.runtimeconfig.json"),
				]),
		]

		Assert.ListEqual(
			expectedBuildOperations,
			SoupTest.operations)
	}

	// [Fact]
	Build_Library_MultipleFiles() {
		// Setup the input build state
		SoupTest.initialize()
		var activeState = SoupTest.activeState
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

		// Setup build table
		var buildTable = {}
		activeState["Build"] = buildTable
		buildTable["Architecture"] = "x64"
		buildTable["Compiler"] = "MOCK"
		buildTable["TargetName"] = "Library"
		buildTable["TargetType"] = BuildTargetType.Library
		buildTable["SourceRootDirectory"] = "C:/source/"
		buildTable["TargetRootDirectory"] = "C:/target/"
		buildTable["ObjectDirectory"] = "obj/"
		buildTable["BinaryDirectory"] = "bin/"
		buildTable["Source"] = [
			"TestFile1.cpp",
			"TestFile2.cpp",
			"TestFile3.cpp",
		]
		buildTable["IncludeDirectories"] = [
			"Folder",
			"AnotherFolder/Sub",
		]
		buildTable["ModuleDependencies"] = [
			"../Other/bin/OtherModule1.mock.bmi",
			"../OtherModule2.mock.bmi",
		]
		buildTable["OptimizationLevel"] = BuildOptimizationLevel.None

		// Setup dotnet table
		var dotnetTable = {}
		activeState["DotNet"] = dotnetTable
		dotnetTable["ExecutablePath"] = "C:/bin/mock.dotnet.exe"

		// Register the mock compiler
		var compiler = MockCompiler.new()
		BuildTask.registerCompiler("MOCK", Fn.new { |activeState| compiler })

		BuildTask.evaluate()

		// Verify expected logs
		Assert.ListEqual(
			[
				"INFO: Using Compiler: MOCK",
				"INFO: Build Generate Done",
			],
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
			Path.new("TestFile1.cpp"),
			Path.new("TestFile2.cpp"),
			Path.new("TestFile3.cpp"),
		]
		expectedCompileArguments.NullableState = NullableState.Enabled

		// Verify expected compiler calls
		Assert.ListEqual(
			[
				expectedCompileArguments,
			],
			compiler.GetCompileRequests())

		// Verify build state
		var expectedBuildOperations = [
			SoupTestOperation.new(
				"MakeDir [./obj/]",
				Path.new("/TARGET/mkdir.exe"),
				[
					"./obj/",
				],
				Path.new("C:/target/"),
				[],
				[
					Path.new("./obj/"),
				]),
			SoupTestOperation.new(
				"MakeDir [./bin/]",
				Path.new("/TARGET/mkdir.exe"),
				[
					"./bin/",
				],
				Path.new("C:/target/"),
				[],
				[
					Path.new("./bin/"),
				]),
			SoupTestOperation.new(
				"MakeDir [./bin/ref/]",
				Path.new("/TARGET/mkdir.exe"),
				[
					"./bin/ref/",
				],
				Path.new("C:/target/"),
				[],
				[
					Path.new("./bin/ref/"),
				]),
			SoupTestOperation.new(
				"MockCompile: 1",
				Path.new("MockCompiler.exe"),
				[
					"Arguments",
				],
				Path.new("MockWorkingDirectory"),
				[
					Path.new("./InputFile.in"),
				],
				[
					Path.new("./OutputFile.out"),
				]),
		]

		Assert.ListEqual(
			expectedBuildOperations,
			SoupTest.operations)
	}
}
