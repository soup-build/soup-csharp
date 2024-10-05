// <copyright file="BuildTaskUnitTests.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

import "soup-test" for SoupTest, SoupTestOperation
import "../../Extension/Tasks/BuildTask" for BuildTask
import "mwasplund|Soup.CSharp.Compiler:./MockCompiler" for MockCompiler
import "mwasplund|Soup.CSharp.Compiler:./BuildOptions" for BuildOptimizationLevel, BuildTargetType
import "mwasplund|Soup.CSharp.Compiler:./CompileOptions" for CompileOptions, NullableState
import "mwasplund|Soup.CSharp.Compiler:./ManagedCompileOptions" for LinkTarget
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
			"mwasplund|mkdir": {
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

		var expectedCompileOptions = CompileOptions.new()
		expectedCompileOptions.OutputAssembly = Path.new("C:/target/bin/Program.mock.dll")
		expectedCompileOptions.OutputRefAssembly = Path.new("C:/target/bin/ref/Program.mock.dll")
		expectedCompileOptions.TargetType = LinkTarget.Executable
		expectedCompileOptions.SourceRootDirectory = Path.new("C:/source/")
		expectedCompileOptions.Sources = [
			Path.new("C:/source/TestFile.cs")
		]
		expectedCompileOptions.NullableState = NullableState.Enabled

		// Verify expected compiler calls
		Assert.ListEqual(
			[
				expectedCompileOptions,
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
    \"tfm\": \"net8.0\",
    \"framework\": {
      \"name\": \"Microsoft.NETCore.App\",
      \"version\": \"8.0.0\"
    },
    \"configProperties\": {
      \"System.Runtime.Serialization.EnableUnsafeBinaryFormatterSerialization\": false
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
			"mwasplund|mkdir": {
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
		var expectedCompileOptions = CompileOptions.new()
		expectedCompileOptions.OutputAssembly = Path.new("C:/target/bin/Library.mock.dll")
		expectedCompileOptions.OutputRefAssembly = Path.new("C:/target/bin/ref/Library.mock.dll")
		expectedCompileOptions.TargetType = LinkTarget.Library
		expectedCompileOptions.SourceRootDirectory = Path.new("C:/source/")
		expectedCompileOptions.Sources = [
			Path.new("C:/source/TestFile1.cpp"),
			Path.new("C:/source/TestFile2.cpp"),
			Path.new("C:/source/TestFile3.cpp"),
		]
		expectedCompileOptions.NullableState = NullableState.Enabled

		// Verify expected compiler calls
		Assert.ListEqual(
			[
				expectedCompileOptions,
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
