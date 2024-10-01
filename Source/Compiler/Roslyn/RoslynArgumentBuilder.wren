// <copyright file="RoslynArgumentBuilder.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

import "mwasplund|Soup.CSharp.Compiler:./CompileOptions" for NullableState
import "mwasplund|Soup.CSharp.Compiler:./ManagedCompileOptions" for LinkTarget
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

		super.BuildResponseFileArguments(options, builder)
	}
}
