// <copyright file="BuildOptions.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

/// <summary>
/// The enumeration of build optimization levels
/// </summary>
class BuildOptimizationLevel {
	/// <summary>
	/// Debug
	/// </summary>
	static None { "None" }

	/// <summary>
	/// Optimize for runtime speed, may sacrifice size
	/// </summary>
	static Speed { "Speed" }

	/// <summary>
	/// Optimize for speed and size
	/// </summary>
	static Size { "Size" }
}

/// <summary>
/// The enumeration of target types
/// </summary>
class BuildTargetType {
	/// <summary>
	/// Executable
	/// </summary>
	static Executable { "Executable" }

	/// <summary>
	/// Library
	/// </summary>
	static Library { "Library" }
}

/// <summary>
/// The enumeration of nullable state
/// </summary>
class BuildNullableState {
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
/// The set of build options
/// </summary>
class BuildOptions {
	construct new() {
		_targetName = null
		_targetArchitecture = null
		_targetType = null
		_sourceRootDirectory = null
		_targetRootDirectory = null
		_objectDirectory = null
		_binaryDirectory = null
		_sourceFiles = []
		_linkDependencies = []
		_libraryPaths = []
		_preprocessorDefinitions = []
		_runtimeDependencies = []
		_optimizationLevel = null
		_generateSourceDebugInfo = false
		_enableWarningsAsErrors = false
		_nullableState = null
		_disabledWarnings = []
		_enabledWarnings = []
		_customProperties = {}
	}

	/// <summary>
	/// Gets or sets the target name
	/// </summary>
	TargetName { _targetName }
	TargetName=(value) { _targetName = value }

	/// <summary>
	/// Gets or sets the target architecture
	/// </summary>
	TargetArchitecture { _targetArchitecture }
	TargetArchitecture=(value) { _targetArchitecture = value }

	/// <summary>
	/// Gets or sets the target type
	/// </summary>
	TargetType { _targetType }
	TargetType=(value) { _targetType = value }

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
	/// Gets or sets the output object directory
	/// </summary>
	ObjectDirectory { _objectDirectory }
	ObjectDirectory=(value) { _objectDirectory = value }

	/// <summary>
	/// Gets or sets the output binary directory
	/// </summary>
	BinaryDirectory { _binaryDirectory }
	BinaryDirectory=(value) { _binaryDirectory = value }

	/// <summary>
	/// Gets or sets the list of source files
	/// </summary>
	SourceFiles { _sourceFiles }
	SourceFiles=(value) { _sourceFiles = value }

	/// <summary>
	/// Gets or sets the list of link libraries
	/// </summary>
	LinkDependencies { _linkDependencies }
	LinkDependencies=(value) { _linkDependencies = value }

	/// <summary>
	/// Gets or sets the list of library paths
	/// </summary>
	LibraryPaths { _libraryPaths }
	LibraryPaths=(value) { _libraryPaths = value }

	/// <summary>
	/// Gets or sets the list of preprocessor definitions
	/// </summary>
	PreprocessorDefinitions { _preprocessorDefinitions }
	PreprocessorDefinitions=(value) { _preprocessorDefinitions = value }

	/// <summary>
	/// Gets or sets the list of runtime dependencies
	/// </summary>
	RuntimeDependencies { _runtimeDependencies }
	RuntimeDependencies=(value) { _runtimeDependencies = value }

	/// <summary>
	/// Gets or sets the optimization level
	/// </summary>
	OptimizationLevel { _optimizationLevel }
	OptimizationLevel=(value) { _optimizationLevel = value }

	/// <summary>
	/// Gets or sets a value indicating whether to generate source debug information
	/// </summary>
	GenerateSourceDebugInfo { _generateSourceDebugInfo }
	GenerateSourceDebugInfo=(value) { _generateSourceDebugInfo = value }

	/// <summary>
	/// Gets or sets a value indicating whether to enable warnings as errors
	/// </summary>
	EnableWarningsAsErrors { _enableWarningsAsErrors }
	EnableWarningsAsErrors=(value) { _enableWarningsAsErrors = value }

	/// <summary>
	/// Gets or sets a the nullable state
	/// </summary>
	NullableState { _nullableState }
	NullableState=(value) { _nullableState = value }

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
	/// Gets or sets the set of custom properties for the known compiler
	/// </summary>
	CustomProperties { _customProperties }
	CustomProperties=(value) { _customProperties = value }
}
