// <copyright file="BuildEngineUnitTests.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

import "soup-test" for SoupTest
import "mwasplund|Soup.CSharp.Compiler:./BuildOptions" for BuildOptions, BuildNullableState, BuildOptimizationLevel, BuildTargetType
import "mwasplund|Soup.CSharp.Compiler:./CompileOptions" for CompileOptions, NullableState
import "mwasplund|Soup.CSharp.Compiler:./ManagedCompileOptions" for LinkTarget
import "mwasplund|Soup.CSharp.Compiler:./BuildEngine" for BuildEngine
import "mwasplund|Soup.CSharp.Compiler:./MockCompiler" for MockCompiler
import "mwasplund|Soup.Build.Utils:./BuildOperation" for BuildOperation
import "mwasplund|Soup.Build.Utils:./Path" for Path
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
			"mwasplund|mkdir": {
				"SharedState": {
					"Build": {
						"RunExecutable": "/TARGET/mkdir.exe"
					}
				}
			}
		}

		// Register the mock compiler
		var compiler = MockCompiler.new()

		// Setup the build options
		var options = BuildOptions.new()
		options.TargetName = "Program"
		options.TargetType = BuildTargetType.Executable
		options.SourceRootDirectory = Path.new("C:/source/")
		options.TargetRootDirectory = Path.new("C:/target/")
		options.ObjectDirectory = Path.new("obj/")
		options.BinaryDirectory = Path.new("bin/")
		options.SourceFiles = [
			Path.new("TestFile.cs"),
		]
		options.OptimizationLevel = BuildOptimizationLevel.None
		options.LinkDependencies = [
			Path.new("../Other/bin/OtherModule1.mock.a"),
			Path.new("../OtherModule2.mock.a"),
		]
		options.NullableState = BuildNullableState.Enabled

		var uut = BuildEngine.new(compiler)
		var result = uut.Execute(options)

		// // Verify expected logs
		Assert.ListEqual(
			[],
			SoupTest.logs)

		var expectedCompileOptions = CompileOptions.new()
		expectedCompileOptions.OutputAssembly = Path.new("C:/target/bin/Program.mock.dll")
		expectedCompileOptions.OutputRefAssembly = Path.new("C:/target/bin/ref/Program.mock.dll")
		expectedCompileOptions.TargetType = LinkTarget.Executable
		expectedCompileOptions.SourceRootDirectory = Path.new("C:/source/")
		expectedCompileOptions.Sources = [
			Path.new("C:/source/TestFile.cs"),
		]
		expectedCompileOptions.References = [
			Path.new("../Other/bin/OtherModule1.mock.a"),
			Path.new("../OtherModule2.mock.a"),
		]
		expectedCompileOptions.NullableState = NullableState.Enabled

		// Verify expected compiler calls
		Assert.ListEqual(
			[
				expectedCompileOptions,
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
    \"tfm\": \"net8.0\",
    \"includedFrameworks\": [
      {
        \"name\": \"Microsoft.NETCore.App\",
        \"version\": \"8.0.8\"
      }
    ],
    \"configProperties\": {
      \"Microsoft.Extensions.DependencyInjection.VerifyOpenGenericServiceTrimmability\": true,
      \"System.ComponentModel.TypeConverter.EnableUnsafeBinaryFormatterInDesigntimeLicenseContextSerialization\": false,
      \"System.Resources.ResourceManager.AllowCustomResourceTypes\": false,
      \"System.Runtime.InteropServices.BuiltInComInterop.IsSupported\": false,
      \"System.Runtime.InteropServices.EnableConsumingManagedCodeFromNativeHosting\": false,
      \"System.Runtime.InteropServices.EnableCppCLIHostActivation\": false,
      \"System.Runtime.InteropServices.Marshalling.EnableGeneratedComInterfaceComImportInterop\": false,
      \"System.Runtime.Serialization.EnableUnsafeBinaryFormatterSerialization\": false,
      \"System.StartupHookProvider.IsSupported\": false,
      \"System.Text.Encoding.EnableUnsafeUTF7Encoding\": false,
      \"System.Text.Json.JsonSerializer.IsReflectionEnabledByDefault\": false,
      \"System.Threading.Thread.EnableAutoreleasePool\": false
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

		// Setup the build options
		var options = BuildOptions.new()
		options.TargetName = "Library"
		options.TargetType = BuildTargetType.Library
		options.SourceRootDirectory = Path.new("C:/source/")
		options.TargetRootDirectory = Path.new("C:/target/")
		options.ObjectDirectory = Path.new("obj/")
		options.BinaryDirectory = Path.new("bin/")
		options.SourceFiles = [
			Path.new("TestFile1.cs"),
			Path.new("TestFile2.cs"),
			Path.new("TestFile3.cs"),
		]
		options.OptimizationLevel = BuildOptimizationLevel.Size
		options.LinkDependencies = [
			Path.new("../Other/bin/OtherModule1.mock.a"),
			Path.new("../OtherModule2.mock.a"),
		]
		options.NullableState = BuildNullableState.Disabled

		var uut = BuildEngine.new(compiler)
		var result = uut.Execute(options)

		// // Verify expected logs
		Assert.ListEqual(
			[],
			SoupTest.logs)

		// Setup the shared arguments
		var expectedCompileOptions = CompileOptions.new()
		expectedCompileOptions.OutputAssembly = Path.new("C:/target//bin/Library.mock.dll")
		expectedCompileOptions.OutputRefAssembly = Path.new("C:/target//bin/ref/Library.mock.dll")
		expectedCompileOptions.TargetType = LinkTarget.Library
		expectedCompileOptions.SourceRootDirectory = Path.new("C:/source/")
		expectedCompileOptions.Sources = [
			Path.new("C:/source/TestFile1.cs"),
			Path.new("C:/source/TestFile2.cs"),
			Path.new("C:/source/TestFile3.cs"),
		]
		expectedCompileOptions.References = [
			Path.new("../Other/bin/OtherModule1.mock.a"),
			Path.new("../OtherModule2.mock.a"),
		]
		expectedCompileOptions.NullableState = NullableState.Disabled

		// Verify expected compiler calls
		Assert.ListEqual(
			[
				expectedCompileOptions,
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