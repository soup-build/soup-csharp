// <copyright file="RoslynArgumentBuilder.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

import "Soup.CSharp.Compiler:./CompileArguments" for LinkTarget, NullableState

/// <summary>
/// A helper class that builds the correct set of compiler arguments for a given
/// set of options.
/// </summary>
class RoslynArgumentBuilder {
	static ArgumentFlag_NoConfig { "noconfig" }

	static BuildSharedCompilerArguments(arguments) {
		// Calculate object output file
		var commandArguments = []

		// Disable 'unsafe' code
		RoslynArgumentBuilder.AddFlag(commandArguments, "unsafe-")

		// Disable generate overflow checks
		RoslynArgumentBuilder.AddFlag(commandArguments, "checked-")

		// Disable warnings
		if (arguments.DisabledWarnings.count > 0) {
			var noWarnList = string.Join(",", arguments.DisabledWarnings)
			RoslynArgumentBuilder.AddParameter(commandArguments, "nowarn", noWarnList)
		}

		// Generate fully qualified paths
		RoslynArgumentBuilder.AddFlag(commandArguments, "fullpaths")

		// Do not reference standard library (mscorlib.dll)
		RoslynArgumentBuilder.AddFlag(commandArguments, "nostdlib+")

		// Specify how to handle internal compiler errors
		RoslynArgumentBuilder.AddParameter(commandArguments, "errorreport", "prompt")

		// Set the warning level
		RoslynArgumentBuilder.AddParameter(commandArguments, "warn", "5")

		// Define conditional compilation symbol(s)
		if (arguments.PreprocessorDefinitions.count > 0) {
			var definesList = arguments.PreprocessorDefinitions.join("")
			RoslynArgumentBuilder.AddParameter(commandArguments, "define", definesList)
		}

		// Output line and column of the end location of each error
		RoslynArgumentBuilder.AddFlag(commandArguments, "errorendlocation")

		// Specify the preferred output language name.
		RoslynArgumentBuilder.AddParameter(commandArguments, "preferreduilang", "en-US")

		// Enable high-entropy ASLR
		RoslynArgumentBuilder.AddFlag(commandArguments, "highentropyva+")

		// Specify nullable context option enabled
		if (arguments.NullableState == NullableState.Disabled) {
			RoslynArgumentBuilder.AddParameter(commandArguments, "nullable", "disable")
		} else if (arguments.NullableState == NullableState.Enabled) {
			RoslynArgumentBuilder.AddParameter(commandArguments, "nullable", "enable")
		} else if (arguments.NullableState == NullableState.Warnings) {
			RoslynArgumentBuilder.AddParameter(commandArguments, "nullable", "warnings")
		} else if (arguments.NullableState == NullableState.Annotations) {
			RoslynArgumentBuilder.AddParameter(commandArguments, "nullable", "annotations")
		} else {
			Fiber.abort("Unknown Nullable State")
		}

		// Add the reference libraries
		for (file in arguments.ReferenceLibraries) {
			RoslynArgumentBuilder.AddParameterWithQuotes(commandArguments, "reference", file.toString)
		}

		// Emit debugging information
		RoslynArgumentBuilder.AddFlag(commandArguments, "debug+")
		RoslynArgumentBuilder.AddParameter(commandArguments, "debug", "portable")

		// Specify the alignment used for output file sections
		RoslynArgumentBuilder.AddParameter(commandArguments, "filealign", "512")

		// Enable optimizations
		if (arguments.EnableOptimizations) {
			RoslynArgumentBuilder.AddFlag(commandArguments, "optimize+")
		} else {
			RoslynArgumentBuilder.AddFlag(commandArguments, "optimize-")
		}

		// Specify output file name
		var absoluteTarget = arguments.TargetRootDirectory + arguments.Target
		RoslynArgumentBuilder.AddParameterWithQuotes(commandArguments, "out", absoluteTarget.toString)

		// Reference assembly output to generate
		var absoluteReferenceTarget = arguments.TargetRootDirectory + arguments.ReferenceTarget
		RoslynArgumentBuilder.AddParameterWithQuotes(commandArguments, "refout", absoluteReferenceTarget.toString)

		if (arguments.TargetType == LinkTarget.Library) {
			RoslynArgumentBuilder.AddParameter(commandArguments, "target", "library")
		} else if (arguments.TargetType == LinkTarget.Executable) {
			RoslynArgumentBuilder.AddParameter(commandArguments, "target", "exe")
		} else {
			Fiber.abort("Unknown Target Type %(arguments.TargetType)")
		}

		// Report all warnings as errors
		if (arguments.EnableWarningsAsErrors) {
			RoslynArgumentBuilder.AddFlag(commandArguments, "warnaserror+")
		} else {
			RoslynArgumentBuilder.AddFlag(commandArguments, "warnaserror-")
		}

		// Output compiler messages in UTF-8 encoding
		RoslynArgumentBuilder.AddFlag(commandArguments, "utf8output")

		// Produce a deterministic assembly
		RoslynArgumentBuilder.AddFlag(commandArguments, "deterministic+")

		// Specify language version
		RoslynArgumentBuilder.AddParameter(commandArguments, "langversion", "9.0")

		// Add the source files
		for (file in arguments.SourceFiles) {
			RoslynArgumentBuilder.AddValueWithQuotes(commandArguments, file.toString)
		}

		return commandArguments
	}

	static BuildUniqueCompilerArguments() {
		// Calculate object output file
		var commandArguments = []

		// Do not auto include CSC.RSP file
		RoslynArgumentBuilder.AddFlag(commandArguments, RoslynArgumentBuilder.ArgumentFlag_NoConfig)

		return commandArguments
	}

	static AddValueWithQuotes(arguments, value) {
		arguments.add("\"%(value)\"")
	}

	static AddFlag(arguments, flag) {
		arguments.add("/%(flag)")
	}

	static AddParameter(arguments, name, value) {
		arguments.add("/%(name):%(value)")
	}

	static AddParameterWithQuotes(arguments, name, value) {
		arguments.add("/%(name):\"%(value)\"")
	}
}
