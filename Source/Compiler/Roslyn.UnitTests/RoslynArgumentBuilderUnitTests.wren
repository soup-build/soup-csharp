// <copyright file="RoslynArgumentBuilderUnitTests.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

import "../Roslyn/RoslynArgumentBuilder" for RoslynArgumentBuilder
import "../Core/CompileArguments" for CompileArguments, LinkTarget, NullableState
import "../../Utils/Path" for Path
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
		var arguments = CompileArguments.new()
		arguments.Target = Path.new("bin/Target.dll")
		arguments.ReferenceTarget = Path.new("ref/Target.dll")
		arguments.TargetRootDirectory = Path.new("./root/")
		arguments.TargetType = LinkTarget.Library
		arguments.NullableState =  NullableState.Enabled

		var actualArguments = RoslynArgumentBuilder.BuildSharedCompilerArguments(
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
		var arguments = CompileArguments.new()
		arguments.Target = Path.new("bin/Target.dll")
		arguments.ReferenceTarget = Path.new("ref/Target.dll")
		arguments.TargetType = LinkTarget.Executable
		arguments.TargetRootDirectory = Path.new("./root/")
		arguments.NullableState =  NullableState.Enabled

		var actualArguments = RoslynArgumentBuilder.BuildSharedCompilerArguments(
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
		var arguments = CompileArguments.new()
		arguments.Target = Path.new("bin/Target.dll")
		arguments.ReferenceTarget = Path.new("ref/Target.dll")
		arguments.TargetRootDirectory = Path.new("./root/")
		arguments.TargetType = LinkTarget.Library
		arguments.NullableState =  NullableState.Enabled
		arguments.EnableWarningsAsErrors = true

		var actualArguments = RoslynArgumentBuilder.BuildSharedCompilerArguments(
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
		var arguments = CompileArguments.new()
		arguments.Target = Path.new("bin/Target.dll")
		arguments.ReferenceTarget = Path.new("ref/Target.dll")
		arguments.TargetRootDirectory = Path.new("./root/")
		arguments.TargetType = LinkTarget.Library
		arguments.NullableState =  NullableState.Enabled
		arguments.GenerateSourceDebugInfo = true

		var actualArguments = RoslynArgumentBuilder.BuildSharedCompilerArguments(
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
		var arguments = CompileArguments.new()
		arguments.Target = Path.new("bin/Target.dll")
		arguments.ReferenceTarget = Path.new("ref/Target.dll")
		arguments.TargetRootDirectory = Path.new("./root/")
		arguments.TargetType = LinkTarget.Library
		arguments.NullableState =  NullableState.Enabled
		arguments.PreprocessorDefinitions = [
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
			"/define:DEBUGVERSION=1",
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
