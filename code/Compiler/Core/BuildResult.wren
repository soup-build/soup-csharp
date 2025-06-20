﻿// <copyright file="BuildResult.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

/// <summary>
/// The build result
/// </summary>
class BuildResult {
	construct new() {
		_buildOperations = []
		_linkDependencies = []
		_internalLinkDependencies = []
		_runtimeDependencies = []
		_targetFile = null
	}

	/// <summary>
	/// Gets or sets the resulting root build operations
	/// </summary>
	BuildOperations { _buildOperations }
	BuildOperations=(value) { _buildOperations = value }

	/// <summary>
	/// Gets or sets the list of link libraries that downstream builds should use when linking
	/// </summary>
	LinkDependencies { _linkDependencies }
	LinkDependencies=(value) { _linkDependencies = value }

	/// <summary>
	/// Gets or sets the list of internal link libraries that were used to link the final result
	/// </summary>
	InternalLinkDependencies { _internalLinkDependencies }
	InternalLinkDependencies=(value) { _internalLinkDependencies = value }

	/// <summary>
	/// Gets or sets the list of runtime dependencies
	/// </summary>
	RuntimeDependencies { _runtimeDependencies }
	RuntimeDependencies=(value) { _runtimeDependencies = value }

	/// <summary>
	/// Gets or sets the target file for the build
	/// </summary>
	TargetFile { _targetFile }
	TargetFile=(value) { _targetFile = value }
}
