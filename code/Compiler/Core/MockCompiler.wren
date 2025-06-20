// <copyright file="MockCompiler.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

import "./ICompiler" for ICompiler
import "Soup|Build.Utils:./BuildOperation" for BuildOperation
import "Soup|Build.Utils:./Path" for Path

/// <summary>
/// A mock compiler interface implementation
/// TODO: Move into test projects
/// </summary>
class MockCompiler is ICompiler {
	/// <summary>
	/// Initializes a new instance of the <see cref='Compiler'/> class.
	/// </summary>
	construct new() {
		_compileRequests = []
	}

	/// <summary>
	/// Get the compile requests
	/// </summary>
	GetCompileRequests() {
		return _compileRequests
	}

	/// <summary>
	/// Gets the unique name for the compiler
	/// </summary>
	Name { "MockCompiler" }

	/// <summary>
	/// Gets the object file extension for the compiler
	/// </summary>
	ObjectFileExtension { "mock.obj" }

	/// <summary>
	/// Gets the static library file extension for the compiler
	/// TODO: This is platform specific
	/// </summary>
	StaticLibraryFileExtension { "mock.lib" }

	/// <summary>
	/// Gets the dynamic library file extension for the compiler
	/// TODO: This is platform specific
	/// </summary>
	DynamicLibraryFileExtension { "mock.dll" }

	/// <summary>
	/// Compile
	/// </summary>
	CreateCompileOperations(options, objectDirectory, targetRootDirectory) {
		_compileRequests.add(options)

		var result = []
		result.add(
			BuildOperation.new(
				"MockCompile: %(_compileRequests.count)",
				Path.new("MockWorkingDirectory"),
				Path.new("MockCompiler.exe"),
				[ "Arguments" ],
				[
					Path.new("InputFile.in"),
				],
				[
					Path.new("OutputFile.out"),
				]))

		return result
	}
}
