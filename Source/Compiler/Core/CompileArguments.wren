// <copyright file="CompilerArguments.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

/// <summary>
/// The enumeration of link targets
/// </summary>
enum LinkTarget {
	/// <summary>
	/// Dynamic Library
	/// </summary>
	Library,

	/// <summary>
	/// Executable
	/// </summary>
	Executable,
}

/// <summary>
/// The enumeration of nullable state
/// </summary>
enum NullableState {
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
/// The set of compiler arguments
/// </summary>
class CompileArguments {
	/// <summary>
	/// Gets or sets the source directory
	/// </summary>
	Path SourceRootDirectory { get init } = new Path()

	/// <summary>
	/// Gets or sets the target directory
	/// </summary>
	Path TargetRootDirectory { get init } = new Path()

	/// <summary>
	/// Gets or sets the object directory
	/// </summary>
	Path ObjectDirectory { get init } = new Path()

	/// <summary>
	/// Gets or sets the list of preprocessor definitions
	/// </summary>
	IReadOnlyList<string> PreprocessorDefinitions { get init } = new List<string>()

	/// <summary>
	/// Gets or sets the list of reference libraries
	/// </summary>
	IReadOnlyList<Path> ReferenceLibraries { get init } = new List<Path>()

	/// <summary>
	/// Gets or sets the list of source files
	/// </summary>
	IReadOnlyList<Path> SourceFiles { get init } = new List<Path>()

	/// <summary>
	/// Gets or sets a value indicating whether to enable optimizations
	/// </summary>
	bool EnableOptimizations { get init }

	/// <summary>
	/// Gets or sets a value indicating whether to generate source debug information
	/// </summary>
	bool GenerateSourceDebugInfo { get init }

	/// <summary>
	/// Gets or sets the target type
	/// </summary>
	LinkTarget TargetType { get init } = LinkTarget.Library

	/// <summary>
	/// Gets or sets the target file
	/// </summary>
	Path Target { get set } = new Path()

	/// <summary>
	/// Gets or sets the reference target file
	/// </summary>
	Path ReferenceTarget { get set } = new Path()

	/// <summary>
	/// Gets or sets a value indicating whether to enable warnings as errors
	/// </summary>
	bool EnableWarningsAsErrors { get init }

	/// <summary>
	/// Gets or sets the list of disabled warnings
	/// </summary>
	IReadOnlyList<string> DisabledWarnings { get set } = new List<string>()

	/// <summary>
	/// Gets or sets the list of enabled warnings
	/// </summary>
	IReadOnlyList<string> EnabledWarnings { get init } = new List<string>()

	/// <summary>
	/// Gets or sets a value indicating whether nullable is enabled
	/// </summary>
	NullableState NullableState {get init } = NullableState.Enabled

	/// <summary>
	/// Gets or sets the set of custom properties for the known compiler
	/// </summary>
	IReadOnlyList<string> CustomProperties { get init } = new List<string>()

	override bool Equals(object? obj) => this.Equals(obj as CompileArguments)

	bool Equals(CompileArguments? rhs)
	{
		if (rhs is null)
			return false

		// Optimization for a common success case.
		if (object.ReferenceEquals(this, rhs))
			return true

		// Return true if the fields match.
		return this.SourceRootDirectory == rhs.SourceRootDirectory &&
			this.TargetRootDirectory == rhs.TargetRootDirectory &&
			this.ObjectDirectory == rhs.ObjectDirectory &&
			Enumerable.SequenceEqual(this.PreprocessorDefinitions, rhs.PreprocessorDefinitions) &&
			Enumerable.SequenceEqual(this.ReferenceLibraries, rhs.ReferenceLibraries) &&
			Enumerable.SequenceEqual(this.SourceFiles, rhs.SourceFiles) &&
			this.EnableOptimizations == rhs.EnableOptimizations &&
			this.GenerateSourceDebugInfo == rhs.GenerateSourceDebugInfo &&
			this.TargetType == rhs.TargetType &&
			this.Target == rhs.Target &&
			this.ReferenceTarget == rhs.ReferenceTarget &&
			this.EnableWarningsAsErrors == rhs.EnableWarningsAsErrors &&
			Enumerable.SequenceEqual(this.DisabledWarnings, rhs.DisabledWarnings) &&
			Enumerable.SequenceEqual(this.EnabledWarnings, rhs.EnabledWarnings) &&
			this.NullableState == rhs.NullableState &&
			Enumerable.SequenceEqual(this.CustomProperties, rhs.CustomProperties)
	}

	override int GetHashCode() => (SourceRootDirectory, TargetRootDirectory, ObjectDirectory, Target).GetHashCode()

	static bool operator ==(CompileArguments? lhs, CompileArguments? rhs)
	{
		if (lhs is null)
		{
			if (rhs is null)
				return true
			else
				return false
		}

		return lhs.Equals(rhs)
	}

	static bool operator !=(CompileArguments? lhs, CompileArguments? rhs) => !(lhs == rhs)

	override string ToString()
	{
		return $"SharedCompileArguments {{ SourceRootDirectory=\"{SourceRootDirectory}\", TargetRootDirectory=\"{TargetRootDirectory}\", ObjectDirectory=\"{ObjectDirectory}\", PreprocessorDefinitions=[{string.Join(",", PreprocessorDefinitions)}], ReferenceLibraries=[{string.Join(",", ReferenceLibraries)}], SourceFiles=[{string.Join(",", SourceFiles)}], EnableOptimizations=\"{EnableOptimizations}\", GenerateSourceDebugInfo=\"{GenerateSourceDebugInfo}\", TargetType={TargetType}, Target={Target}, ReferenceTarget={ReferenceTarget}, EnableWarningsAsErrors=\"{EnableWarningsAsErrors}\", DisabledWarnings=[{string.Join(",", DisabledWarnings)}], EnabledWarnings=[{string.Join(",", EnabledWarnings)}], NullableState=\"{NullableState}\" CustomProperties=[{string.Join(",", CustomProperties)}]}}"
	}
}
