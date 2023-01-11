// <copyright file="ArgumentBuilder.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

/// <summary>
/// A helper class that builds the correct set of compiler arguments for a given
/// set of options.
/// </summary>
class ArgumentBuilder {
	static ArgumentFlag_NoConfig { "noconfig" }

	static BuildSharedCompilerArguments(CompileArguments arguments)
	{
		// Calculate object output file
		var commandArguments = []

		// Disable 'unsafe' code
		AddFlag(commandArguments, "unsafe-")

		// Disable generate overflow checks
		AddFlag(commandArguments, "checked-")

		// Disable warnings
		if (arguments.DisabledWarnings.Count > 0) {
			var noWarnList = string.Join(",", arguments.DisabledWarnings)
			AddParameter(commandArguments, "nowarn", noWarnList)
		}

		// Generate fully qualified paths
		AddFlag(commandArguments, "fullpaths")

		// Do not reference standard library (mscorlib.dll)
		AddFlag(commandArguments, "nostdlib+")

		// Specify how to handle internal compiler errors
		AddParameter(commandArguments, "errorreport", "prompt")

		// Set the warning level
		AddParameter(commandArguments, "warn", "5")

		// Define conditional compilation symbol(s)
		if (arguments.PreprocessorDefinitions.Count > 0) {
			var definesList = string.Join("", arguments.PreprocessorDefinitions)
			AddParameter(commandArguments, "define", definesList)
		}

		// Output line and column of the end location of each error
		AddFlag(commandArguments, "errorendlocation")

		// Specify the preferred output language name.
		AddParameter(commandArguments, "preferreduilang", "en-US")

		// Enable high-entropy ASLR
		AddFlag(commandArguments, "highentropyva+")

		// Specify nullable context option enabled
		switch (arguments.NullableState)
		{
			case NullableState.Disabled:
				AddParameter(commandArguments, "nullable", "disable")
				break
			case NullableState.Enabled:
				AddParameter(commandArguments, "nullable", "enable")
				break
			case NullableState.Warnings:
				AddParameter(commandArguments, "nullable", "warnings")
				break
			case NullableState.Annotations:
				AddParameter(commandArguments, "nullable", "annotations")
				break
			default:
				Fiber.abort("Unknown Nullable State")
		}

		// Add the reference libraries
		for (file in arguments.ReferenceLibraries) {
			AddParameterWithQuotes(commandArguments, "reference", file.ToString())
		}

		// Emit debugging information
		AddFlag(commandArguments, "debug+")
		AddParameter(commandArguments, "debug", "portable")

		// Specify the alignment used for output file sections
		AddParameter(commandArguments, "filealign", "512")

		// Enable optimizations
		if (arguments.EnableOptimizations) {
			AddFlag(commandArguments, "optimize+")
		} else {
			AddFlag(commandArguments, "optimize-")
		}

		// Specify output file name
		var absoluteTarget = arguments.TargetRootDirectory + arguments.Target
		AddParameterWithQuotes(commandArguments, "out", absoluteTarget.ToString())

		// Reference assembly output to generate
		var absoluteReferenceTarget = arguments.TargetRootDirectory + arguments.ReferenceTarget
		AddParameterWithQuotes(commandArguments, "refout", absoluteReferenceTarget.ToString())

		switch (arguments.TargetType)
		{
			case LinkTarget.Library:
				AddParameter(commandArguments, "target", "library")
				break
			case LinkTarget.Executable:
				AddParameter(commandArguments, "target", "exe")
				break
			default:
				Fiber.abort($"Unknown Target Type {arguments.TargetType}")
		}

		// Report all warnings as errors
		if (arguments.EnableWarningsAsErrors) {
			AddFlag(commandArguments, "warnaserror+")
		} else {
			AddFlag(commandArguments, "warnaserror-")
		}

		// Output compiler messages in UTF-8 encoding
		AddFlag(commandArguments, "utf8output")

		// Produce a deterministic assembly
		AddFlag(commandArguments, "deterministic+")

		// Specify language version
		AddParameter(commandArguments, "langversion", "9.0")

		// Add the source files
		for (file in arguments.SourceFiles) {
			AddValueWithQuotes(commandArguments, file.ToString())
		}

		return commandArguments
	}

	static BuildUniqueCompilerArguments() {
		// Calculate object output file
		var commandArguments = []

		// Do not auto include CSC.RSP file
		AddFlag(commandArguments, ArgumentFlag_NoConfig)

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
