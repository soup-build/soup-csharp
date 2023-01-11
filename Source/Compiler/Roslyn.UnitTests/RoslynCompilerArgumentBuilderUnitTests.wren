// <copyright file="RoslynCompilerArgumentBuilderUnitTests.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

class RoslynCompilerArgumentBuilderTests {
	RunTests() {
		System.print("RoslynCompilerArgumentBuilderTests.BuildSharedCompilerArguments_DefaultParameters")
		BuildSharedCompilerArguments_DefaultParameters()
		System.print("RoslynCompilerArgumentBuilderTests.BuildSharedCompilerArguments_SingleArgument_Executable")
		BuildSharedCompilerArguments_SingleArgument_Executable()
		System.print("RoslynCompilerArgumentBuilderTests.BuildSharedCompilerArguments_SingleArgument_NetModule")
		BuildSharedCompilerArguments_SingleArgument_NetModule()
		System.print("RoslynCompilerArgumentBuilderTests.BuildSharedCompilerArguments_SingleArgument_EnableWarningsAsErrors")
		BuildSharedCompilerArguments_SingleArgument_EnableWarningsAsErrors()
		System.print("RoslynCompilerArgumentBuilderTests.BuildSharedCompilerArguments_SingleArgument_GenerateDebugInformation")
		BuildSharedCompilerArguments_SingleArgument_GenerateDebugInformation()
		System.print("RoslynCompilerArgumentBuilderTests.BuildSharedCompilerArguments_SingleArgument_PreprocessorDefinitions")
		BuildSharedCompilerArguments_SingleArgument_PreprocessorDefinitions()
		System.print("RoslynCompilerArgumentBuilderTests.BuildUniqueCompilerArguments")
		BuildUniqueCompilerArguments()
	}

	// [Fact]
	BuildSharedCompilerArguments_DefaultParameters() {
		var arguments = CompileArguments.new()
		arguments.Target = Path.new("bin/Target.dll")
		arguments.ReferenceTarget = Path.new("ref/Target.dll")

		var actualArguments = ArgumentBuilder.BuildSharedCompilerArguments(
			arguments)

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
			"/out:\"./bin/Target.dll\"",
			"/refout:\"./ref/Target.dll\"",
			"/target:library",
			"/warnaserror-",
			"/utf8output",
			"/deterministic+",
			"/langversion:9.0",
		]

		Assert.Equal(expectedArguments, actualArguments)
	}

	// [Fact]
	BuildSharedCompilerArguments_SingleArgument_Executable() {
		var arguments = CompileArguments.new()
		arguments.Target = Path.new("bin/Target.dll")
		arguments.ReferenceTarget = Path.new("ref/Target.dll")
		arguments.TargetType = LinkTarget.Executable

		var actualArguments = ArgumentBuilder.BuildSharedCompilerArguments(
			arguments)

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
			"/out:\"./bin/Target.dll\"",
			"/refout:\"./ref/Target.dll\"",
			"/target:exe",
			"/warnaserror-",
			"/utf8output",
			"/deterministic+",
			"/langversion:9.0",
		]

		Assert.Equal(expectedArguments, actualArguments)
	}

	// [Fact]
	BuildSharedCompilerArguments_SingleArgument_NetModule() {
		var arguments = CompileArguments.new()
		arguments.Target = Path.new("bin/Target.netmodule")
		arguments.TargetType = LinkTarget.Module

		var actualArguments = ArgumentBuilder.BuildSharedCompilerArguments(
			arguments)

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
			"/out:\"./bin/Target.netmodule\"",
			"/target:module",
			"/warnaserror-",
			"/utf8output",
			"/deterministic+",
			"/langversion:9.0",
		]

		Assert.Equal(expectedArguments, actualArguments)
	}

	// [Fact]
	BuildSharedCompilerArguments_SingleArgument_EnableWarningsAsErrors() {
		var arguments = CompileArguments.new()
		arguments.Target = Path.new("bin/Target.dll")
		arguments.ReferenceTarget = Path.new("ref/Target.dll")
		arguments.EnableWarningsAsErrors = true

		var actualArguments = ArgumentBuilder.BuildSharedCompilerArguments(
			arguments)

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
			"/out:\"./bin/Target.dll\"",
			"/refout:\"./ref/Target.dll\"",
			"/target:library",
			"/warnaserror+",
			"/utf8output",
			"/deterministic+",
			"/langversion:9.0",
		]

		Assert.Equal(expectedArguments, actualArguments)
	}

	// [Fact]
	BuildSharedCompilerArguments_SingleArgument_GenerateDebugInformation() {
		var arguments = CompileArguments.new()
		arguments.Target = Path.new("bin/Target.dll")
		arguments.ReferenceTarget = Path.new("ref/Target.dll")
		arguments.GenerateSourceDebugInfo = true

		var actualArguments = ArgumentBuilder.BuildSharedCompilerArguments(
			arguments)

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
			"/out:\"./bin/Target.dll\"",
			"/refout:\"./ref/Target.dll\"",
			"/target:library",
			"/warnaserror-",
			"/utf8output",
			"/deterministic+",
			"/langversion:9.0",
		]

		Assert.Equal(expectedArguments, actualArguments)
	}

	// [Fact]
	BuildSharedCompilerArguments_SingleArgument_PreprocessorDefinitions() {
		var arguments = CompileArguments.new()
		arguments.Target = Path.new("bin/Target.dll")
		arguments.ReferenceTarget = Path.new("ref/Target.dll")
		arguments.PreprocessorDefinitions = [
			"DEBUG",
			"VERSION=1"
		]

		var actualArguments = ArgumentBuilder.BuildSharedCompilerArguments(
			arguments)

		var expectedArguments = [
			"/unsafe-",
			"/checked-",
			"/fullpaths",
			"/nostdlib+",
			"/errorreport:prompt",
			"/warn:5",
			"/define:DEBUGVERSION=1",
			"/errorendlocation",
			"/preferreduilang:en-US",
			"/highentropyva+",
			"/nullable:enable",
			"/debug+",
			"/debug:portable",
			"/filealign:512",
			"/optimize-",
			"/out:\"./bin/Target.dll\"",
			"/refout:\"./ref/Target.dll\"",
			"/target:library",
			"/warnaserror-",
			"/utf8output",
			"/deterministic+",
			"/langversion:9.0",
		]

		Assert.Equal(expectedArguments, actualArguments)
	}

	// [Fact]
	BuildUniqueCompilerArguments() {
		var actualArguments = ArgumentBuilder.BuildUniqueCompilerArguments()

		var expectedArguments = [
			"/noconfig",
		]

		Assert.Equal(expectedArguments, actualArguments)
	}
}
