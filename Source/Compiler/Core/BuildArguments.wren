// <copyright file="BuildArguments.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

/// <summary>
/// The enumeration of build optimization levels
/// </summary>
enum BuildOptimizationLevel {
	/// <summary>
	/// Debug
	/// </summary>
	None,

	/// <summary>
	/// Optimize for runtime speed, may sacrifice size
	/// </summary>
	Speed,

	/// <summary>
	/// Optimize for speed and size
	/// </summary>
	Size,
}

/// <summary>
/// The enumeration of target types
/// </summary>
enum BuildTargetType {
	/// <summary>
	/// Executable
	/// </summary>
	Executable,

	/// <summary>
	/// Library
	/// </summary>
	Library,
}

/// <summary>
/// The enumeration of nullable state
/// </summary>
enum BuildNullableState {
	/// <summary>
	/// Enabled
	/// </summary>
	Enabled,

	/// <summary>
	/// Disabled
	/// </summary>
	Disabled,

	/// <summary>
	/// Annotations
	/// </summary>
	Annotations,

	/// <summary>
	/// Warnings
	/// </summary>
	Warnings,
}

/// <summary>
/// The set of build arguments
/// </summary>
class BuildArguments {
	/// <summary>
	/// Gets or sets the target name
	/// </summary>
	string TargetName { get set } = string.Empty

	/// <summary>
	/// Gets or sets the target architecture
	/// </summary>
	string TargetArchitecture { get set } = string.Empty

	/// <summary>
	/// Gets or sets the target type
	/// </summary>
	BuildTargetType TargetType { get set }

	/// <summary>
	/// Gets or sets the source directory
	/// </summary>
	Path SourceRootDirectory { get set } = new Path()

	/// <summary>
	/// Gets or sets the target directory
	/// </summary>
	Path TargetRootDirectory { get set } = new Path()

	/// <summary>
	/// Gets or sets the output object directory
	/// </summary>
	Path ObjectDirectory { get set } = new Path()

	/// <summary>
	/// Gets or sets the output binary directory
	/// </summary>
	Path BinaryDirectory { get set } = new Path()

	/// <summary>
	/// Gets or sets the list of source files
	/// </summary>
	IReadOnlyList<Path> SourceFiles { get set } = new List<Path>()

	/// <summary>
	/// Gets or sets the list of link libraries
	/// </summary>
	IReadOnlyList<Path> LinkDependencies { get set } = new List<Path>()

	/// <summary>
	/// Gets or sets the list of library paths
	/// </summary>
	IReadOnlyList<Path> LibraryPaths { get set } = new List<Path>()

	/// <summary>
	/// Gets or sets the list of preprocessor definitions
	/// </summary>
	IReadOnlyList<string> PreprocessorDefinitions { get set } = new List<string>()

	/// <summary>
	/// Gets or sets the list of runtime dependencies
	/// </summary>
	IReadOnlyList<Path> RuntimeDependencies { get set } = new List<Path>()

	/// <summary>
	/// Gets or sets the optimization level
	/// </summary>
	BuildOptimizationLevel OptimizationLevel { get set }

	/// <summary>
	/// Gets or sets a value indicating whether to generate source debug information
	/// </summary>
	bool GenerateSourceDebugInfo { get set }

	/// <summary>
	/// Gets or sets a value indicating whether to enable warnings as errors
	/// </summary>
	bool EnableWarningsAsErrors { get set }

	/// <summary>
	/// Gets or sets a the nullable state
	/// </summary>
	BuildNullableState NullableState { get set }

	/// <summary>
	/// Gets or sets the list of disabled warnings
	/// </summary>
	IReadOnlyList<string> DisabledWarnings { get set } = new List<string>()

	/// <summary>
	/// Gets or sets the list of enabled warnings
	/// </summary>
	IReadOnlyList<string> EnabledWarnings { get set } = new List<string>()

	/// <summary>
	/// Gets or sets the set of custom properties for the known compiler
	/// </summary>
	IReadOnlyList<string> CustomProperties { get set } = new List<string>()
}
