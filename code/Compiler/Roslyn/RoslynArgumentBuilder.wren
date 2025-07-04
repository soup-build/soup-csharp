// <copyright file="RoslynArgumentBuilder.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

import "Soup|CSharp.Compiler:./CompileOptions" for NullableState
import "Soup|CSharp.Compiler:./ManagedCompileOptions" for LinkTarget
import "./ManagedArgumentBuilder" for ManagedArgumentBuilder

/// <summary>
/// A helper class that builds the correct set of compiler arguments for a given
/// set of options.
/// </summary>
class RoslynArgumentBuilder is ManagedArgumentBuilder {
	construct new() {
	}

	BuildCommandLineArguments(options, builder) {
		super.BuildCommandLineArguments(options, builder)
	}

	BuildResponseFileArguments(options, builder) {
		//builder.AppendSwitchIfNotNull("/lib:", options.AdditionalLibPaths, ",")
		builder.AppendPlusOrMinusSwitch("unsafe", options.AllowUnsafeBlocks)
		builder.AppendPlusOrMinusSwitch("checked", options.CheckForOverflowUnderflow)
		builder.AppendParameterArrayIfNotEmpty("nowarn", options.DisabledWarnings, ",")
		builder.AppendIfTrue("fullpaths", options.GenerateFullPaths)
		// builder.AppendSwitchIfNotNull("moduleassemblyname:", options.ModuleAssemblyName)
		// builder.AppendSwitchIfNotNull("pdb:", options.PdbFile)
		builder.AppendPlusOrMinusSwitch("nostdlib", options.NoStandardLib)
		// builder.AppendSwitchIfNotNull("platform:", options.PlatformWith32BitPreference)
		builder.AppendSwitchIfNotNull("errorreport", options.ErrorReport)
		builder.AppendSwitch("warn", options.WarningLevel)
		// builder.AppendSwitchIfNotNull("/doc:", options.DocumentationFile)
		// builder.AppendSwitchIfNotNull("/baseaddress:", options.BaseAddress)
		builder.AppendParameterArrayIfNotEmpty("define", options.DefineConstants, ";")
		// builder.AppendSwitchIfNotNull("/win32res:", options.Win32Resource)
		// builder.AppendSwitchIfNotNull("/main:", options.MainEntryPoint)
		// builder.AppendSwitchIfNotNull("/appconfig:",options. ApplicationConfiguration)
		builder.AppendIfTrue("errorendlocation", options.ErrorEndLocation)
		builder.AppendSwitchIfNotNull("preferreduilang", options.PreferredUILang)
		builder.AppendPlusOrMinusSwitch("highentropyva", options.HighEntropyVA)
		builder.AppendSwitchIfNotNull("nullable", options.Nullable)
		// builder.AppendIfTrue("/nosdkpath", options.DisableSdkPath)

		RoslynArgumentBuilder.AddReferencesToCommandLine(options.References, builder)

		super.BuildResponseFileArguments(options, builder)

		// This should come after the "TreatWarningsAsErrors" flag is processed (in managedcompiler.cs).
		// Because if TreatWarningsAsErrors=false, then we'll have a /warnaserror- on the command-line,
		// and then any specific warnings that should be treated as errors should be specified with
		// /warnaserror+:<list> after the /warnaserror- switch.  The order of the switches on the command-line
		// does matter.
		//
		// Note that
		//      /warnaserror+
		// is just shorthand for:
		//      /warnaserror+:<all possible warnings>
		//
		// Similarly,
		//      /warnaserror-
		// is just shorthand for:
		//      /warnaserror-:<all possible warnings>
		//builder.AppendSwitchWithSplitting("/warnaserror+:", options.WarningsAsErrors, ",", '', ',')
		//builder.AppendSwitchWithSplitting("/warnaserror-:", options.WarningsNotAsErrors, ",", '', ',')
	}
	
	/// <summary>
	/// The C# compiler (starting with Whidbey) supports assembly aliasing for references.
	/// See spec at http://devdiv/spectool/Documents/Whidbey/VCSharp/Design%20Time/M3%20DCRs/DCR%20Assembly%20aliases.doc.
	/// This method handles the necessary work of looking at the "Aliases" attribute on
	/// the incoming "References" items, and making sure to generate the correct
	/// command-line on csc.exe.  The syntax for aliasing a reference is:
	///     csc.exe /reference:Goo=System.Xml.dll
	///
	/// The "Aliases" attribute on the "References" items is actually a comma-separated
	/// list of aliases, and if any of the aliases specified is the string "global",
	/// then we add that reference to the command-line without an alias.
	/// </summary>
	static AddReferencesToCommandLine(
		references, builder) {
		// Loop through all the references passed in.  We'll be adding separate
		// /reference: switches for each reference, and in some cases even multiple
		// /reference: switches per reference.
		for (reference in references) {
			// See if there was an "Alias" attribute on the reference.
			var aliasString = null // reference.GetMetadata("Aliases")

			var switchName = "reference"

			// bool embed = Utilities.TryConvertItemMetadataToBool(
			// 	reference, "EmbedInteropTypes")
			// if (embed)
			// {
			// 	switchName = "/link:"
			// }

			if (aliasString is Null) {
				// If there was no "Alias" attribute, just add this as a global reference.
				builder.AppendSwitchWithQuotes(switchName, reference)
			} else {
				// // If there was an "Alias" attribute, it contains a comma-separated list
				// // of aliases to use for this reference.  For each one of those aliases,
				// // we're going to add a separate /reference: switch to the csc.exe
				// // command-line
				// string[] aliases = aliasString.Split(',')

				// foreach (string alias in aliases)
				// {
				// 	// Trim whitespace.
				// 	string trimmedAlias = alias.Trim()

				// 	if (alias.Length == 0)
				// 	{
				// 		continue
				// 	}

				// 	// The alias should be a valid C# identifier.  Therefore it cannot
				// 	// contain comma, space, semicolon, or double-quote.  Let's check for
				// 	// the existence of those characters right here, and bail immediately
				// 	// if any are present.  There are a whole bunch of other characters
				// 	// that are not allowed in a C# identifier, but we'll just let csc.exe
				// 	// error out on those.  The ones we're checking for here are the ones
				// 	// that could seriously screw up the command-line parsing or could
				// 	// allow parameter injection.
				// 	if (trimmedAlias.IndexOfAny(new char[] { ',', ' ', '', '"' }) != -1)
				// 	{
				// 		throw Utilities.GetLocalizedArgumentException(
				// 			ErrorString.Csc_AssemblyAliasContainsIllegalCharacters,
				// 			reference.ItemSpec,
				// 			trimmedAlias)
				// 	}

				// 	// The alias called "global" is special.  It means that we don't
				// 	// give it an alias on the command-line.
				// 	if (string.Compare("global", trimmedAlias, StringComparison.OrdinalIgnoreCase) == 0)
				// 	{
				// 		commandLine.AppendSwitchIfNotNull(switchName, reference.ItemSpec)
				// 	}
				// 	else
				// 	{
				// 		// We have a valid (and explicit) alias for this reference.  Add
				// 		// it to the command-line using the syntax:
				// 		//      /reference:Goo=System.Xml.dll
				// 		commandLine.AppendSwitchAliased(switchName, trimmedAlias, reference.ItemSpec)
				// 	}
				// }
			}
		}
	}
}
