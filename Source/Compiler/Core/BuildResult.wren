// <copyright file="BuildResult.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

/// <summary>
/// The build result
/// </summary>
class BuildResult {
	/// <summary>
	/// Gets or sets the resulting root build operations
	/// </summary>
	IList<BuildOperation> BuildOperations { get set } = new List<BuildOperation>()

	/// <summary>
	/// Gets or sets the list of link libraries that downstream builds should use when linking
	/// </summary>
	IList<Path> LinkDependencies { get set } = new List<Path>()

	/// <summary>
	/// Gets or sets the list of internal link libraries that were used to link the final result
	/// </summary>
	IList<Path> InternalLinkDependencies { get set } = new List<Path>()

	/// <summary>
	/// Gets or sets the list of runtime dependencies
	/// </summary>
	IList<Path> RuntimeDependencies { get set } = new List<Path>()

	/// <summary>
	/// Gets or sets the target file for the build
	/// </summary>
	Path TargetFile { get set } = new Path()
}
