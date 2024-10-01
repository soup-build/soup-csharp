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
		// If outputAssembly is not specified, then an "/out: <name>" option won't be added to
		// overwrite the one resulting from the OutputAssembly member of the CompilerParameters class.
		// In that case, we should set the outputAssembly member based on the first source file.
		// if ((OutputAssembly == null) &&
		// 	(Sources != null) &&
		// 	(Sources.Length > 0) &&
		// 	(ResponseFiles == null))
		// {
		// 	try
		// 	{
		// 		OutputAssembly = new TaskItem(Path.GetFileNameWithoutExtension(Sources[0].ItemSpec))
		// 	}
		// 	catch (ArgumentException e)
		// 	{
		// 		throw new ArgumentException(e.Message, "Sources")
		// 	}
		// 	if (string.Compare(TargetType, "library", StringComparison.OrdinalIgnoreCase) == 0)
		// 	{
		// 		OutputAssembly.ItemSpec += ".dll"
		// 	}
		// 	else if (string.Compare(TargetType, "module", StringComparison.OrdinalIgnoreCase) == 0)
		// 	{
		// 		OutputAssembly.ItemSpec += ".netmodule"
		// 	}
		// 	else
		// 	{
		// 		OutputAssembly.ItemSpec += ".exe"
		// 	}
		// }

		// builder.AppendSwitchIfNotNull("/addmodule:", AddModules, ",")
		// builder.AppendSwitchWithInteger("/codepage:", _store, nameof(CodePage))

		// ConfigureDebugProperties()

		// The "DebugType" parameter should be processed after the "EmitDebugInformation" parameter
		// because it's more specific.  Order matters on the command-line, and the last one wins.
		// /debug+ is just a shorthand for /debug:full.  And /debug- is just a shorthand for /debug:none.

		builder.AppendPlusOrMinusSwitch("debug", options.EmitDebugInformation)
		builder.AppendSwitchIfNotNull("debug", options.DebugType)

		// builder.AppendPlusOrMinusSwitch("/delaysign", _store, nameof(DelaySign))

		// builder.AppendIfTrue("/reportivts", _store, nameof(ReportIVTs))

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

		// AddAnalyzersToCommandLine(commandLine, Analyzers)
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
	// /// Adds a "/analyzer:" switch to the command line for each provided analyzer.
	// /// </summary>
	// internal static void AddAnalyzersToCommandLine(CommandLineBuilderExtension commandLine, ITaskItem[]? analyzers)
	// {
	// 	// If there were no analyzers passed in, don't add any /analyzer: switches
	// 	// on the command-line.
	// 	if (analyzers == null)
	// 	{
	// 		return
	// 	}

	// 	foreach (ITaskItem analyzer in analyzers)
	// 	{
	// 		builder.AppendSwitchIfNotNull("/analyzer:", analyzer.ItemSpec)
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

	// /// <summary>
	// /// Configure the debug switches which will be placed on the compiler command-line.
	// /// The matrix of debug type and symbol inputs and the desired results is as follows:
	// ///
	// /// Debug Symbols              DebugType   Desired Results
	// ///          True               Full        /debug+ /debug:full
	// ///          True               PdbOnly     /debug+ /debug:PdbOnly
	// ///          True               None        /debug-
	// ///          True               Blank       /debug+
	// ///          False              Full        /debug- /debug:full
	// ///          False              PdbOnly     /debug- /debug:PdbOnly
	// ///          False              None        /debug-
	// ///          False              Blank       /debug-
	// ///          Blank              Full                /debug:full
	// ///          Blank              PdbOnly             /debug:PdbOnly
	// ///          Blank              None        /debug-
	// /// Debug:   Blank              Blank       /debug+ //Microsoft.common.targets will set this
	// /// Release: Blank              Blank       "Nothing for either switch"
	// ///
	// /// The logic is as follows:
	// /// If debugtype is none  set debugtype to empty and debugSymbols to false
	// /// If debugType is blank  use the debugsymbols "as is"
	// /// If debug type is set, use its value and the debugsymbols value "as is"
	// /// </summary>
	// private void ConfigureDebugProperties()
	// {
	// 	// If debug type is set we need to take some action depending on the value. If debugtype is not set
	// 	// We don't need to modify the EmitDebugInformation switch as its value will be used as is.
	// 	if (_store[nameof(DebugType)] != null)
	// 	{
	// 		// If debugtype is none then only show debug- else use the debug type and the debugsymbols as is.
	// 		if (string.Compare((string?)_store[nameof(DebugType)], "none", StringComparison.OrdinalIgnoreCase) == 0)
	// 		{
	// 			_store[nameof(DebugType)] = null
	// 			_store[nameof(EmitDebugInformation)] = false
	// 		}
	// 	}
	// }
}
