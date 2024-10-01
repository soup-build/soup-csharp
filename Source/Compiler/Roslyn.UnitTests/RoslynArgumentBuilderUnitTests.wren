// <copyright file="RoslynArgumentBuilderUnitTests.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

import "mwasplund|Soup.CSharp.Compiler.Roslyn:./CommandLineBuilder" for CommandLineBuilder
import "mwasplund|Soup.CSharp.Compiler.Roslyn:./RoslynArgumentBuilder" for RoslynArgumentBuilder
import "mwasplund|Soup.CSharp.Compiler:./CompileOptions" for CompileOptions, NullableState
import "mwasplund|Soup.CSharp.Compiler:./ManagedCompileOptions" for LinkTarget
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
		System.print("RoslynArgumentBuilderUnitTests.BuildCommandLineArguments")
		this.BuildCommandLineArguments()
	}

	// [Fact]
	BSCA_DefaultParameters() {
		var options = CompileOptions.new()
		options.OutputAssembly = Path.new("./root/bin/Target.dll")
		options.OutputRefAssembly = Path.new("./root/ref/Target.dll")
		options.TargetType = LinkTarget.Library
		options.NullableState =  NullableState.Enabled

		var responseFileBuilder = CommandLineBuilder.new()
		var agumentBuilder = RoslynArgumentBuilder.new()
		agumentBuilder.BuildResponseFileArguments(
			options, responseFileBuilder)

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

		Assert.ListEqual(expectedArguments, responseFileBuilder.CommandArguments)
	}

	// [Fact]
	BSCA_SingleArgument_Executable() {
		var options = CompileOptions.new()
		options.OutputAssembly = Path.new("./root/bin/Target.dll")
		options.OutputRefAssembly = Path.new("./root/ref/Target.dll")
		options.TargetType = LinkTarget.Executable
		options.NullableState =  NullableState.Enabled

		var responseFileBuilder = CommandLineBuilder.new()
		var agumentBuilder = RoslynArgumentBuilder.new()
		agumentBuilder.BuildResponseFileArguments(
			options, responseFileBuilder)

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

		Assert.ListEqual(expectedArguments, responseFileBuilder.CommandArguments)
	}

	// [Fact]
	BSCA_SingleArgument_EnableWarningsAsErrors() {
		var options = CompileOptions.new()
		options.OutputAssembly = Path.new("./root/bin/Target.dll")
		options.OutputRefAssembly = Path.new("./root/ref/Target.dll")
		options.TargetType = LinkTarget.Library
		options.NullableState =  NullableState.Enabled
		options.TreatWarningsAsErrors = true

		var responseFileBuilder = CommandLineBuilder.new()
		var agumentBuilder = RoslynArgumentBuilder.new()
		agumentBuilder.BuildResponseFileArguments(
			options, responseFileBuilder)

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

		Assert.ListEqual(expectedArguments, responseFileBuilder.CommandArguments)
	}

	// [Fact]
	BSCA_SingleArgument_GenerateDebugInformation() {
		var options = CompileOptions.new()
		options.OutputAssembly = Path.new("./root/bin/Target.dll")
		options.OutputRefAssembly = Path.new("./root/ref/Target.dll")
		options.TargetType = LinkTarget.Library
		options.NullableState =  NullableState.Enabled
		options.GenerateSourceDebugInfo = true

		var responseFileBuilder = CommandLineBuilder.new()
		var agumentBuilder = RoslynArgumentBuilder.new()
		agumentBuilder.BuildResponseFileArguments(
			options, responseFileBuilder)

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

		Assert.ListEqual(expectedArguments, responseFileBuilder.CommandArguments)
	}

	// [Fact]
	BSCA_SingleArgument_PreprocessorDefinitions() {
		var options = CompileOptions.new()
		options.OutputAssembly = Path.new("./root/bin/Target.dll")
		options.OutputRefAssembly = Path.new("./root/ref/Target.dll")
		options.TargetType = LinkTarget.Library
		options.NullableState =  NullableState.Enabled
		options.DefineConstants = [
			"DEBUG",
			"VERSION=1"
		]

		var responseFileBuilder = CommandLineBuilder.new()
		var agumentBuilder = RoslynArgumentBuilder.new()
		agumentBuilder.BuildResponseFileArguments(
			options, responseFileBuilder)

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

		Assert.ListEqual(expectedArguments, responseFileBuilder.CommandArguments)
	}

	// [Fact]
	BuildCommandLineArguments() {
		var options = CompileOptions.new()
		var commandLineBuilder = CommandLineBuilder.new()
		var agumentBuilder = RoslynArgumentBuilder.new()
		var actualArguments = agumentBuilder.BuildCommandLineArguments(options, commandLineBuilder)

		var expectedArguments = [
			"/noconfig"
		]

		Assert.ListEqual(expectedArguments, commandLineBuilder.CommandArguments)
	}
}
