// <copyright file="compile-options.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

import "Soup|Build.Utils:./list-extensions" for ListExtensions
import "./managed-compile-options" for ManagedCompileOptions

/// <summary>
/// The enumeration of nullable state
/// </summary>
class NullableState {
	/// <summary>
	/// Enabled
	/// </summary>
	static Enabled { "Enabled" }

	/// <summary>
	/// Disabled
	/// </summary>
	static Disabled { "Disabled" }

	/// <summary>
	/// Annotations
	/// </summary>
	static Annotations { "Annotations" }

	/// <summary>
	/// Warnings
	/// </summary>
	static Warnings { "Warnings" }
}

/// <summary>
/// The set of compiler options
/// </summary>
class CompileOptions is ManagedCompileOptions {
	construct new() {
		super()
		_sourceRootDirectory = null
		_defineConstants = []
		_references = []
		_enableOptimizations = false
		_generateSourceDebugInfo = false
		_target = null
		_referenceTarget = null
		_allowUnsafeBlocks = false
		_checkForOverflowUnderflow = false
		_errorReport = "prompt"
		_warningLevel = 8
		_errorEndLocation = false
		_preferredUILang = null
		_highEntropyVA = true
		_nullable = "enable"
		_generateFullPaths = true
		_noStandardLib = true
		_disabledWarnings = []
		_enabledWarnings = []
		_nullableState = null
		_customProperties = {}
	}

	/// <summary>
	/// Gets or sets the source directory
	/// </summary>
	SourceRootDirectory { _sourceRootDirectory }
	SourceRootDirectory=(value) { _sourceRootDirectory = value }

	/// <summary>
	/// Gets or sets the list of preprocessor definitions
	/// </summary>
	DefineConstants { _defineConstants }
	DefineConstants=(value) { _defineConstants = value }

	/// <summary>
	/// Gets or sets the list of references
	/// </summary>
	References { _references }
	References=(value) { _references = value }

	/// <summary>
	/// Gets or sets a value indicating whether to enable optimizations
	/// </summary>
	EnableOptimizations { _enableOptimizations }
	EnableOptimizations=(value) { _enableOptimizations = value }

	/// <summary>
	/// Gets or sets a value indicating whether to generate source debug information
	/// </summary>
	GenerateSourceDebugInfo { _generateSourceDebugInfo }
	GenerateSourceDebugInfo=(value) { _generateSourceDebugInfo = value }

	/// <summary>
	/// Gets or sets a value indicating if unsafe blocks are allowed
	/// </summary>
	AllowUnsafeBlocks { _allowUnsafeBlocks }
	AllowUnsafeBlocks=(value) { _allowUnsafeBlocks = value }
	
	/// <summary>
	/// Gets or sets a value indicating if overflow and underflow checks are enabled
	/// </summary>
	CheckForOverflowUnderflow { _checkForOverflowUnderflow }
	CheckForOverflowUnderflow=(value) { _checkForOverflowUnderflow = value }

	/// <summary>
	/// Gets or sets a value indicating if full paths should be generated
	/// </summary>
	GenerateFullPaths { _generateFullPaths }
	GenerateFullPaths=(value) { _generateFullPaths = value }

	/// <summary>
	/// Gets or sets a value indicating if the standard library should not be used
	/// </summary>
	NoStandardLib { _noStandardLib }
	NoStandardLib=(value) { _noStandardLib = value }

	/// <summary>
	/// Gets or sets the error report type
	/// </summary>
	ErrorReport { _errorReport }
	ErrorReport=(value) { _errorReport = value }

	/// <summary>
	/// Gets or sets the warning level
	/// </summary>
	WarningLevel { _warningLevel }
	WarningLevel=(value) { _warningLevel = value }

	/// <summary>
	/// Gets or sets a value indicating whether to show error end location
	/// </summary>
	ErrorEndLocation { _errorEndLocation }
	ErrorEndLocation=(value) { _errorEndLocation = value }

	/// <summary>
	/// Gets or sets the preferred UI language
	/// </summary>
	PreferredUILang { _preferredUILang }
	PreferredUILang=(value) { _preferredUILang = value }

	/// <summary>
	/// Gets or sets a value indicating whether to enable high entropy VA
	/// </summary>
	HighEntropyVA { _highEntropyVA }
	HighEntropyVA=(value) { _highEntropyVA = value }

	/// <summary>
	/// Gets or sets the nullable state
	/// </summary>
	Nullable { _nullable }
	Nullable=(value) { _nullable = value }

	/// <summary>
	/// Gets or sets the list of disabled warnings
	/// </summary>
	DisabledWarnings { _disabledWarnings }
	DisabledWarnings=(value) { _disabledWarnings = value }

	/// <summary>
	/// Gets or sets the list of enabled warnings
	/// </summary>
	EnabledWarnings { _enabledWarnings }
	EnabledWarnings=(value) { _enabledWarnings = value }

	/// <summary>
	/// Gets or sets a value indicating whether nullable is enabled
	/// </summary>
	NullableState { _nullableState }
	NullableState=(value) { _nullableState = value }

	/// <summary>
	/// Gets or sets the set of custom properties for the known compiler
	/// </summary>
	CustomProperties { _customProperties }
	CustomProperties=(value) { _customProperties = value }

	==(rhs) {
		if (rhs is Null) {
			return false
		}

		// Return true if the fields match.
		return super.Equals(rhs) &&
			this.SourceRootDirectory == rhs.SourceRootDirectory &&
			ListExtensions.SequenceEqual(this.DefineConstants, rhs.DefineConstants) &&
			ListExtensions.SequenceEqual(this.References, rhs.References) &&
			this.EnableOptimizations == rhs.EnableOptimizations &&
			this.GenerateSourceDebugInfo == rhs.GenerateSourceDebugInfo &&
			this.AllowUnsafeBlocks == rhs.AllowUnsafeBlocks &&
			this.CheckForOverflowUnderflow == rhs.CheckForOverflowUnderflow &&
			this.GenerateFullPaths == rhs.GenerateFullPaths &&
			this.NoStandardLib == rhs.NoStandardLib &&
			this.ErrorReport == rhs.ErrorReport &&
			this.WarningLevel == rhs.WarningLevel &&
			this.ErrorEndLocation == rhs.ErrorEndLocation &&
			this.PreferredUILang == rhs.PreferredUILang &&
			this.HighEntropyVA == rhs.HighEntropyVA &&
			this.Nullable == rhs.Nullable &&
			ListExtensions.SequenceEqual(this.DisabledWarnings, rhs.DisabledWarnings) &&
			ListExtensions.SequenceEqual(this.EnabledWarnings, rhs.EnabledWarnings) &&
			this.NullableState == rhs.NullableState &&
			ListExtensions.SequenceEqual(this.CustomProperties, rhs.CustomProperties)
	}

	toString {
		return "CompileOptions { %(super.toString), SourceRootDirectory=\"%(_sourceRootDirectory)\", DefineConstants=%(_defineConstants), References=%(_references), EnableOptimizations=\"%(_enableOptimizations)\", GenerateSourceDebugInfo=\"%(_generateSourceDebugInfo)\", TargetType=%(_targetType), Target=%(_target), ReferenceTarget=%(_referenceTarget), DisabledWarnings=%(_disabledWarnings), EnabledWarnings=%(_enabledWarnings), NullableState=\"%(_nullableState)\" CustomProperties=%(_customProperties) }"
	}
}
