// <copyright file="ManagedArgumentBuilder.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

/// <summary>
/// A helper class that builds the correct set of compiler arguments for all managed
/// compilers.
/// </summary>
class ManagedArgumentBuilder  {
	BuildCommandLineArguments(options, builder) {
		builder.AppendIfTrue("noconfig", options.NoConfig)
	}

	BuildResponseFileArguments(options, builder) {
		builder.AppendParameterArrayIfNotEmpty("addmodule", options.AddModules, ",")
		builder.AppendSwitchIfNotNull("codepage", options.CodePage)

		// The "DebugType" parameter should be processed after the "EmitDebugInformation" parameter
		// because it's more specific. Order matters on the command-line, and the last one wins.
		// /debug+ is just a shorthand for /debug:full.  And /debug- is just a shorthand for /debug:none.
		builder.AppendPlusOrMinusSwitch("debug", options.EmitDebugInformation)
		builder.AppendSwitchIfNotNull("debug", options.DebugType)

		builder.AppendPlusOrMinusSwitchIfNotNull("delaysign", options.DelaySign)

		builder.AppendIfTrue("reportivts", options.ReportIVTs)

		builder.AppendSwitch("filealign", options.FileAlignment)
		// builder.AppendSwitchIfNotNull("/generatedfilesout:", GeneratedFilesOutputPath)
		// builder.AppendSwitchIfNotNull("/keycontainer:", KeyContainer)
		// builder.AppendSwitchIfNotNull("/keyfile:", KeyFile)
		// // If the strings "LogicalName" or "Access" ever change, make sure to search/replace everywhere in vsproject.
		// builder.AppendSwitchIfNotNull("/linkresource:", LinkResources, new string[] { "LogicalName", "Access" })
		// builder.AppendIfTrue("/nologo", _store, nameof(NoLogo))
		// builder.AppendIfTrue("/nowin32manifest", _store, nameof(NoWin32Manifest))
		builder.AppendPlusOrMinusSwitch("optimize", options.Optimize)
		// builder.AppendSwitchIfNotNull("/pathmap:", PathMap)
		builder.AppendSwitchWithQuotesIfNotNull("out", options.OutputAssembly)
		builder.AppendSwitchWithQuotesIfNotNull("refout", options.OutputRefAssembly)
		// builder.AppendIfTrue("/refonly", _store, nameof(RefOnly))
		// builder.AppendSwitchIfNotNull("/ruleset:", CodeAnalysisRuleSet)
		// builder.AppendSwitchIfNotNull("/errorlog:", ErrorLog)
		// builder.AppendSwitchIfNotNull("/subsystemversion:", SubsystemVersion)
		// builder.AppendIfTrue("/reportanalyzer", _store, nameof(ReportAnalyzer))
		// // If the strings "LogicalName" or "Access" ever change, make sure to search/replace everywhere in vsproject.
		// builder.AppendSwitchIfNotNull("/resource:", Resources, new string[] { "LogicalName", "Access" })
		builder.AppendSwitchIfNotNull("target", options.TargetType)
		builder.AppendPlusOrMinusSwitch("warnaserror", options.TreatWarningsAsErrors)
		builder.AppendIfTrue("utf8output", options.Utf8Output)
		// builder.AppendSwitchIfNotNull("/win32icon:", Win32Icon)
		// builder.AppendSwitchIfNotNull("/win32manifest:", Win32Manifest)

		builder.AppendPlusOrMinusSwitch("deterministic", options.Deterministic)
	// 	builder.AppendPlusOrMinusSwitch("/publicsign", _store, nameof(PublicSign))
	// 	builder.AppendSwitchIfNotNull("/runtimemetadataversion:", RuntimeMetadataVersion)
	// 	builder.AppendSwitchIfNotNull("/checksumalgorithm:", ChecksumAlgorithm)
	// 	builder.AppendSwitchWithSplitting("/instrument:", Instrument, ",", '', ',')
	// 	builder.AppendSwitchIfNotNull("/sourcelink:", SourceLink)
		builder.AppendSwitchIfNotNull("langversion", options.LangVersion)
	// 	builder.AppendPlusOrMinusSwitch("/skipanalyzers", _store, nameof(SkipAnalyzers))

	// 	AddFeatures(commandLine, Features)
	// 	AddEmbeddedFilesToCommandLine(commandLine)
	// 	AddAnalyzerConfigFilesToCommandLine(commandLine)

		for (analyzer in options.Analyzers) {
			builder.AppendSwitchWithQuotes("analyzer", analyzer)
		}

		// AddAdditionalFilesToCommandLine(commandLine)

		// Append the sources.
		builder.AppendArrayQuoted(options.Sources)
	}

	// /// <summary>
	// /// Adds a "/features:" switch to the command line for each provided feature.
	// /// </summary>
	// internal static void AddFeatures(CommandLineBuilderExtension commandLine, string? features)
	// {
	// 	if (RoslynString.IsNullOrEmpty(features))
	// 	{
	// 		return
	// 	}

	// 	foreach (var feature in CompilerOptionParseUtilities.ParseFeatureFromMSBuild(features))
	// 	{
	// 		builder.AppendSwitchIfNotNull("/features:", feature.Trim())
	// 	}
	// }

	// /// <summary>
	// /// Adds a "/additionalfile:" switch to the command line for each additional file.
	// /// </summary>
	// private void AddAdditionalFilesToCommandLine(CommandLineBuilderExtension commandLine)
	// {
	// 	if (AdditionalFiles != null)
	// 	{
	// 		foreach (ITaskItem additionalFile in AdditionalFiles)
	// 		{
	// 			builder.AppendSwitchIfNotNull("/additionalfile:", additionalFile.ItemSpec)
	// 		}
	// 	}
	// }

	// /// <summary>
	// /// Adds a "/embed:" switch to the command line for each pdb embedded file.
	// /// </summary>
	// private void AddEmbeddedFilesToCommandLine(CommandLineBuilderExtension commandLine)
	// {
	// 	if (EmbedAllSources)
	// 	{
	// 		builder.AppendSwitch("/embed")
	// 	}

	// 	if (EmbeddedFiles != null)
	// 	{
	// 		foreach (ITaskItem embeddedFile in EmbeddedFiles)
	// 		{
	// 			builder.AppendSwitchIfNotNull("/embed:", embeddedFile.ItemSpec)
	// 		}
	// 	}
	// }

	// /// <summary>
	// /// Adds a "/editorconfig:" switch to the command line for each .editorconfig file.
	// /// </summary>
	// private void AddAnalyzerConfigFilesToCommandLine(CommandLineBuilderExtension commandLine)
	// {
	// 	if (AnalyzerConfigFiles != null)
	// 	{
	// 		foreach (ITaskItem analyzerConfigFile in AnalyzerConfigFiles)
	// 		{
	// 			builder.AppendSwitchIfNotNull("/analyzerconfig:", analyzerConfigFile.ItemSpec)
	// 		}
	// 	}
	// }
}
