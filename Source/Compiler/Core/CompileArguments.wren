// <copyright file="CompilerArguments.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

import "mwasplund|Soup.Build.Utils:./ListExtensions" for ListExtensions

/// <summary>
/// The enumeration of link targets
/// </summary>
class LinkTarget {
	/// <summary>
	/// Dynamic Library
	/// </summary>
	static Library { "Library" }

	/// <summary>
	/// Executable
	/// </summary>
	static Executable { "Executable" }
}

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
/// The set of compiler arguments
/// </summary>
class CompileArguments {
	construct new() {
		_sourceRootDirectory = null
		_targetRootDirectory = null
		_objectDirectory = null
		_preprocessorDefinitions = []
		_referenceLibraries = []
		_sourceFiles = []
		_enableOptimizations = false
		_generateSourceDebugInfo = false
		_targetType = null
		_target = null
		_referenceTarget = null
		_enableWarningsAsErrors = false
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
	/// Gets or sets the target directory
	/// </summary>
	TargetRootDirectory { _targetRootDirectory }
	TargetRootDirectory=(value) { _targetRootDirectory = value }

	/// <summary>
	/// Gets or sets the object directory
	/// </summary>
	ObjectDirectory { _objectDirectory }
	ObjectDirectory=(value) { _objectDirectory = value }

	/// <summary>
	/// Gets or sets the list of preprocessor definitions
	/// </summary>
	PreprocessorDefinitions { _preprocessorDefinitions }
	PreprocessorDefinitions=(value) { _preprocessorDefinitions = value }

	/// <summary>
	/// Gets or sets the list of reference libraries
	/// </summary>
	ReferenceLibraries { _referenceLibraries }
	ReferenceLibraries=(value) { _referenceLibraries = value }

	/// <summary>
	/// Gets or sets the list of source files
	/// </summary>
	SourceFiles { _sourceFiles }
	SourceFiles=(value) { _sourceFiles = value }

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
	/// Gets or sets the target type
	/// </summary>
	TargetType { _targetType }
	TargetType=(value) { _targetType = value }

	/// <summary>
	/// Gets or sets the target file
	/// </summary>
	Target { _target }
	Target=(value) { _target = value }

	/// <summary>
	/// Gets or sets the reference target file
	/// </summary>
	ReferenceTarget { _referenceTarget }
	ReferenceTarget=(value) { _referenceTarget = value }

	/// <summary>
	/// Gets or sets a value indicating whether to enable warnings as errors
	/// </summary>
	EnableWarningsAsErrors { _enableWarningsAsErrors }
	EnableWarningsAsErrors=(value) { _enableWarningsAsErrors = value }

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
		return this.SourceRootDirectory == rhs.SourceRootDirectory &&
			this.TargetRootDirectory == rhs.TargetRootDirectory &&
			this.ObjectDirectory == rhs.ObjectDirectory &&
			ListExtensions.SequenceEqual(this.PreprocessorDefinitions, rhs.PreprocessorDefinitions) &&
			ListExtensions.SequenceEqual(this.ReferenceLibraries, rhs.ReferenceLibraries) &&
			ListExtensions.SequenceEqual(this.SourceFiles, rhs.SourceFiles) &&
			this.EnableOptimizations == rhs.EnableOptimizations &&
			this.GenerateSourceDebugInfo == rhs.GenerateSourceDebugInfo &&
			this.TargetType == rhs.TargetType &&
			this.Target == rhs.Target &&
			this.ReferenceTarget == rhs.ReferenceTarget &&
			this.EnableWarningsAsErrors == rhs.EnableWarningsAsErrors &&
			ListExtensions.SequenceEqual(this.DisabledWarnings, rhs.DisabledWarnings) &&
			ListExtensions.SequenceEqual(this.EnabledWarnings, rhs.EnabledWarnings) &&
			this.NullableState == rhs.NullableState &&
			ListExtensions.SequenceEqual(this.CustomProperties, rhs.CustomProperties)
	}

	toString {
		return "CompileArguments { SourceRootDirectory=\"%(_sourceRootDirectory)\", TargetRootDirectory=\"%(_targetRootDirectory)\", ObjectDirectory=\"%(_objectDirectory)\", PreprocessorDefinitions=%(_preprocessorDefinitions), ReferenceLibraries=%(_referenceLibraries), SourceFiles=%(_sourceFiles), EnableOptimizations=\"%(_enableOptimizations)\", GenerateSourceDebugInfo=\"%(_generateSourceDebugInfo)\", TargetType=%(_targetType), Target=%(_target), ReferenceTarget=%(_referenceTarget), EnableWarningsAsErrors=\"%(_enableWarningsAsErrors)\", DisabledWarnings=%(_disabledWarnings), EnabledWarnings=%(_enabledWarnings), NullableState=\"%(_nullableState)\" CustomProperties=%(_customProperties) }"
	}
}
