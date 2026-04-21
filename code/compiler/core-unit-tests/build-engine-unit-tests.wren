// <copyright file="build-engine-unit-tests.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

import "soup-test" for SoupTest
import "soup|csharp-compiler:./build-options" for BuildOptions, BuildNullableState, BuildOptimizationLevel, BuildTargetType
import "soup|csharp-compiler:./compile-options" for CompileOptions, NullableState
import "soup|csharp-compiler:./managed-compile-options" for LinkTarget
import "soup|csharp-compiler:./build-engine" for BuildEngine
import "soup|csharp-compiler:./mock-compiler" for MockCompiler
import "soup|build-utils:./build-operation" for BuildOperation
import "soup|build-utils:./path" for Path
import "../../test/assert" for Assert

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
		options.TargetName = "my-program"
		options.TargetVersion = "1.2.3"
		options.TargetFramework = "net8.0"
		options.TargetType = BuildTargetType.Executable
		options.SourceRootDirectory = Path.new("C:/source/")
		options.TargetRootDirectory = Path.new("C:/target/")
		options.ObjectDirectory = Path.new("obj/")
		options.BinaryDirectory = Path.new("bin/")
		options.GenerateDirectory = Path.new("gen/")
		options.Flavor = "Debug"
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

		// Verify expected logs
		Assert.ListEqual(
			[],
			SoupTest.logs)

		var expectedCompileOptions = CompileOptions.new()
		expectedCompileOptions.OutputAssembly = Path.new("C:/target/bin/my-program.mock.dll")
		expectedCompileOptions.OutputRefAssembly = Path.new("C:/target/bin/ref/my-program.mock.dll")
		expectedCompileOptions.TargetType = LinkTarget.Executable
		expectedCompileOptions.SourceRootDirectory = Path.new("C:/source/")
		expectedCompileOptions.Sources = [
			Path.new("C:/source/TestFile.cs"),
			Path.new("C:/target/gen/.NETCoreApp,Version=v8.0.AssemblyAttributes.cs"),
			Path.new("C:/target/gen/my-program.AssemblyInfo.cs"),
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
				"MakeDir [./gen/]",
				Path.new("C:/target/"),
				Path.new("/TARGET/mkdir.exe"),
				[
					"./gen/",
				],
				[],
				[
					Path.new("./gen/"),
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
				"WriteFile [./bin/my-program.runtimeconfig.json]",
				Path.new("C:/target/"),
				Path.new("./writefile.exe"),
				[
					"./bin/my-program.runtimeconfig.json",
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
				[],
				[
					Path.new("./bin/my-program.runtimeconfig.json"),
				]),
			BuildOperation.new(
				"WriteFile [./gen/.NETCoreApp,Version=v8.0.AssemblyAttributes.cs]",
				Path.new("C:/target/"),
				Path.new("./writefile.exe"),
				[
					"./gen/.NETCoreApp,Version=v8.0.AssemblyAttributes.cs",
					"// <autogenerated />
using System;
using System.Reflection;
[assembly: global::System.Runtime.Versioning.TargetFrameworkAttribute(\".NETCoreApp,Version=v8.0\", FrameworkDisplayName = \".NET 8.0\")]

",
				],
				[],
				[
					Path.new("./gen/.NETCoreApp,Version=v8.0.AssemblyAttributes.cs"),
				]),
			BuildOperation.new(
				"WriteFile [./gen/my-program.AssemblyInfo.cs]",
				Path.new("C:/target/"),
				Path.new("./writefile.exe"),
				[
					"./gen/my-program.AssemblyInfo.cs",
					"//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

using System;
using System.Reflection;

[assembly: System.Reflection.AssemblyCompanyAttribute(\"my-program\")]
[assembly: System.Reflection.AssemblyConfigurationAttribute(\"Debug\")]
[assembly: System.Reflection.AssemblyFileVersionAttribute(\"1.2.3\")]
[assembly: System.Reflection.AssemblyInformationalVersionAttribute(\"1.2.3+8513519b4c322896f461ecdcdb42594a66d6889a\")]
[assembly: System.Reflection.AssemblyProductAttribute(\"my-program\")]
[assembly: System.Reflection.AssemblyTitleAttribute(\"my-program\")]
[assembly: System.Reflection.AssemblyVersionAttribute(\"1.2.3\")]

// Generated by the MSBuild WriteCodeFragment class.

",
				],
				[],
				[
					Path.new("./gen/my-program.AssemblyInfo.cs"),
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
		]

		Assert.ListEqual(
			expectedBuildOperations,
			result.BuildOperations)

		Assert.ListEqual(
			[],
			result.LinkDependencies)

		Assert.ListEqual(
			[
				Path.new("C:/target/bin/my-program.mock.dll"),
			],
			result.RuntimeDependencies)
	}

	// [Fact]
	Build_Library_MultipleFiles() {
		// Register the mock compiler
		var compiler = MockCompiler.new()

		// Setup the build options
		var options = BuildOptions.new()
		options.TargetName = "my-library"
		options.TargetVersion = "1.2.3"
		options.TargetFramework = "net8.0"
		options.TargetType = BuildTargetType.Library
		options.SourceRootDirectory = Path.new("C:/source/")
		options.TargetRootDirectory = Path.new("C:/target/")
		options.ObjectDirectory = Path.new("obj/")
		options.BinaryDirectory = Path.new("bin/")
		options.GenerateDirectory = Path.new("gen/")
		options.Flavor = "Debug"
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

		// Verify expected logs
		Assert.ListEqual(
			[],
			SoupTest.logs)

		// Setup the shared arguments
		var expectedCompileOptions = CompileOptions.new()
		expectedCompileOptions.OutputAssembly = Path.new("C:/target/bin/my-library.mock.dll")
		expectedCompileOptions.OutputRefAssembly = Path.new("C:/target/bin/ref/my-library.mock.dll")
		expectedCompileOptions.TargetType = LinkTarget.Library
		expectedCompileOptions.SourceRootDirectory = Path.new("C:/source/")
		expectedCompileOptions.Sources = [
			Path.new("C:/source/TestFile1.cs"),
			Path.new("C:/source/TestFile2.cs"),
			Path.new("C:/source/TestFile3.cs"),
			Path.new("C:/target/gen/.NETCoreApp,Version=v8.0.AssemblyAttributes.cs"),
			Path.new("C:/target/gen/my-library.AssemblyInfo.cs"),
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
				"MakeDir [./gen/]",
				Path.new("C:/target/"),
				Path.new("/TARGET/mkdir.exe"),
				[
					"./gen/",
				],
				[],
				[
					Path.new("./gen/"),
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
				"WriteFile [./gen/.NETCoreApp,Version=v8.0.AssemblyAttributes.cs]",
				Path.new("C:/target/"),
				Path.new("./writefile.exe"),
				[
					"./gen/.NETCoreApp,Version=v8.0.AssemblyAttributes.cs",
					"// <autogenerated />
using System;
using System.Reflection;
[assembly: global::System.Runtime.Versioning.TargetFrameworkAttribute(\".NETCoreApp,Version=v8.0\", FrameworkDisplayName = \".NET 8.0\")]

",
				],
				[],
				[
					Path.new("./gen/.NETCoreApp,Version=v8.0.AssemblyAttributes.cs"),
				]),
			BuildOperation.new(
				"WriteFile [./gen/my-library.AssemblyInfo.cs]",
				Path.new("C:/target/"),
				Path.new("./writefile.exe"),
				[
					"./gen/my-library.AssemblyInfo.cs",
					"//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

using System;
using System.Reflection;

[assembly: System.Reflection.AssemblyCompanyAttribute(\"my-library\")]
[assembly: System.Reflection.AssemblyConfigurationAttribute(\"Debug\")]
[assembly: System.Reflection.AssemblyFileVersionAttribute(\"1.2.3\")]
[assembly: System.Reflection.AssemblyInformationalVersionAttribute(\"1.2.3+8513519b4c322896f461ecdcdb42594a66d6889a\")]
[assembly: System.Reflection.AssemblyProductAttribute(\"my-library\")]
[assembly: System.Reflection.AssemblyTitleAttribute(\"my-library\")]
[assembly: System.Reflection.AssemblyVersionAttribute(\"1.2.3\")]

// Generated by the MSBuild WriteCodeFragment class.

",
				],
				[],
				[
					Path.new("./gen/my-library.AssemblyInfo.cs"),
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
				Path.new("C:/target/bin/ref/my-library.mock.dll"),
				Path.new("../Other/bin/OtherModule1.mock.a"),
				Path.new("../OtherModule2.mock.a"),
			],
			result.LinkDependencies)

		Assert.ListEqual(
			[
				Path.new("C:/target/bin/my-library.mock.dll"),
			],
			result.RuntimeDependencies)

		Assert.Equal(
			Path.new("C:/target/bin/my-library.mock.dll"),
			result.TargetFile)
	}
}