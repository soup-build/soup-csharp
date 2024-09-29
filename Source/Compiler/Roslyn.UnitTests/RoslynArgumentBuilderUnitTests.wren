// <copyright file="RoslynArgumentBuilderUnitTests.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

import "mwasplund|Soup.CSharp.Compiler.Roslyn:./RoslynArgumentBuilder" for RoslynArgumentBuilder
import "mwasplund|Soup.CSharp.Compiler:./CompileOptions" for CompileOptions, LinkTarget, NullableState
import "mwasplund|Soup.Build.Utils:./Path" for Path
import "../../Test/Assert" for Assert

class RoslynArgumentBuilderUnitTests {
	construct new() {
	}

	RunTests() {
		System.print("RoslynArgumentBuilderUnitTests.BSCA_DefaultParameters")
		this.BSCA_DefaultParameters()
		System.print("RoslynArgumentBuilderUnitTests.BSCA_SingleArgument_Executable")
		this.BSCA_SingleArgument_Executable()
		System.print("RoslynArgumentBuilderUnitTests.BSCA_SingleArgument_EnableWarningsAsErrors")
		this.BSCA_SingleArgument_EnableWarningsAsErrors()
		System.print("RoslynArgumentBuilderUnitTests.BSCA_SingleArgument_GenerateDebugInformation")
		this.BSCA_SingleArgument_GenerateDebugInformation()
		System.print("RoslynArgumentBuilderUnitTests.BSCA_SingleArgument_PreprocessorDefinitions")
		this.BSCA_SingleArgument_PreprocessorDefinitions()
		System.print("RoslynArgumentBuilderUnitTests.BuildUniqueCompilerArguments")
		this.BuildUniqueCompilerArguments()
	}

	// [Fact]
	BSCA_DefaultParameters() {
		var options = CompileOptions.new()
		options.Target = Path.new("bin/Target.dll")
		options.ReferenceTarget = Path.new("ref/Target.dll")
		options.TargetRootDirectory = Path.new("./root/")
		options.TargetType = LinkTarget.Library
		options.NullableState =  NullableState.Enabled

		var actualArguments = RoslynArgumentBuilder.BuildSharedCompilerArguments(
			options)

		var expectedArguments = [
			"/unsafe-",
			"/checked-",
			"/fullpaths",
			"/nostdlib+",
			"/errorreport:prompt",
			"/warn:5",
			"/errorendlocation",
			"/preferreduilang:en-US",
			"/highentropyva+",
			"/nullable:enable",
			"/debug+",
			"/debug:portable",
			"/filealign:512",
			"/optimize-",
			"/out:\"./root/bin/Target.dll\"",
			"/refout:\"./root/ref/Target.dll\"",
			"/target:library",
			"/warnaserror-",
			"/utf8output",
			"/deterministic+",
			"/langversion:9.0",
		]

		Assert.ListEqual(expectedArguments, actualArguments)
	}

	// [Fact]
	BSCA_SingleArgument_Executable() {
		var options = CompileOptions.new()
		options.Target = Path.new("bin/Target.dll")
		options.ReferenceTarget = Path.new("ref/Target.dll")
		options.TargetType = LinkTarget.Executable
		options.TargetRootDirectory = Path.new("./root/")
		options.NullableState =  NullableState.Enabled

		var actualArguments = RoslynArgumentBuilder.BuildSharedCompilerArguments(
			options)

		var expectedArguments = [
			"/unsafe-",
			"/checked-",
			"/fullpaths",
			"/nostdlib+",
			"/errorreport:prompt",
			"/warn:5",
			"/errorendlocation",
			"/preferreduilang:en-US",
			"/highentropyva+",
			"/nullable:enable",
			"/debug+",
			"/debug:portable",
			"/filealign:512",
			"/optimize-",
			"/out:\"./root/bin/Target.dll\"",
			"/refout:\"./root/ref/Target.dll\"",
			"/target:exe",
			"/warnaserror-",
			"/utf8output",
			"/deterministic+",
			"/langversion:9.0",
		]

		Assert.ListEqual(expectedArguments, actualArguments)
	}

	// [Fact]
	BSCA_SingleArgument_EnableWarningsAsErrors() {
		var options = CompileOptions.new()
		options.Target = Path.new("bin/Target.dll")
		options.ReferenceTarget = Path.new("ref/Target.dll")
		options.TargetRootDirectory = Path.new("./root/")
		options.TargetType = LinkTarget.Library
		options.NullableState =  NullableState.Enabled
		options.EnableWarningsAsErrors = true

		var actualArguments = RoslynArgumentBuilder.BuildSharedCompilerArguments(
			options)

		var expectedArguments = [
			"/unsafe-",
			"/checked-",
			"/fullpaths",
			"/nostdlib+",
			"/errorreport:prompt",
			"/warn:5",
			"/errorendlocation",
			"/preferreduilang:en-US",
			"/highentropyva+",
			"/nullable:enable",
			"/debug+",
			"/debug:portable",
			"/filealign:512",
			"/optimize-",
			"/out:\"./root/bin/Target.dll\"",
			"/refout:\"./root/ref/Target.dll\"",
			"/target:library",
			"/warnaserror+",
			"/utf8output",
			"/deterministic+",
			"/langversion:9.0",
		]

		Assert.ListEqual(expectedArguments, actualArguments)
	}

	// [Fact]
	BSCA_SingleArgument_GenerateDebugInformation() {
		var options = CompileOptions.new()
		options.Target = Path.new("bin/Target.dll")
		options.ReferenceTarget = Path.new("ref/Target.dll")
		options.TargetRootDirectory = Path.new("./root/")
		options.TargetType = LinkTarget.Library
		options.NullableState =  NullableState.Enabled
		options.GenerateSourceDebugInfo = true

		var actualArguments = RoslynArgumentBuilder.BuildSharedCompilerArguments(
			options)

		var expectedArguments = [
			"/unsafe-",
			"/checked-",
			"/fullpaths",
			"/nostdlib+",
			"/errorreport:prompt",
			"/warn:5",
			"/errorendlocation",
			"/preferreduilang:en-US",
			"/highentropyva+",
			"/nullable:enable",
			"/debug+",
			"/debug:portable",
			"/filealign:512",
			"/optimize-",
			"/out:\"./root/bin/Target.dll\"",
			"/refout:\"./root/ref/Target.dll\"",
			"/target:library",
			"/warnaserror-",
			"/utf8output",
			"/deterministic+",
			"/langversion:9.0",
		]

		Assert.ListEqual(expectedArguments, actualArguments)
	}

	// [Fact]
	BSCA_SingleArgument_PreprocessorDefinitions() {
		var options = CompileOptions.new()
		options.Target = Path.new("bin/Target.dll")
		options.ReferenceTarget = Path.new("ref/Target.dll")
		options.TargetRootDirectory = Path.new("./root/")
		options.TargetType = LinkTarget.Library
		options.NullableState =  NullableState.Enabled
		options.PreprocessorDefinitions = [
			"DEBUG",
			"VERSION=1"
		]

		var actualArguments = RoslynArgumentBuilder.BuildSharedCompilerArguments(
			arguments)

		var expectedArguments = [
			"/unsafe-",
			"/checked-",
			"/fullpaths",
			"/nostdlib+",
			"/errorreport:prompt",
			"/warn:5",
			"/define:DEBUG;VERSION=1",
			"/errorendlocation",
			"/preferreduilang:en-US",
			"/highentropyva+",
			"/nullable:enable",
			"/debug+",
			"/debug:portable",
			"/filealign:512",
			"/optimize-",
			"/out:\"./root/bin/Target.dll\"",
			"/refout:\"./root/ref/Target.dll\"",
			"/target:library",
			"/warnaserror-",
			"/utf8output",
			"/deterministic+",
			"/langversion:9.0",
		]

		Assert.ListEqual(expectedArguments, actualArguments)
	}

	// [Fact]
	BuildUniqueCompilerArguments() {
		var actualArguments = RoslynArgumentBuilder.BuildUniqueCompilerArguments()

		var expectedArguments = [
			"/noconfig",
		]

		Assert.ListEqual(expectedArguments, actualArguments)
	}
}
