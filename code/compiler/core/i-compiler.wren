// <copyright file="i-compiler.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

/// <summary>
/// The compiler interface definition
/// </summary>
class ICompiler {
	/// <summary>
	/// Gets the unique name for the compiler
	/// </summary>
	Name { }

	/// <summary>
	/// Gets the object file extension for the compiler
	/// </summary>
	ObjectFileExtension { }

	/// <summary>
	/// Gets the static library file extension for the compiler
	/// TODO: This is platform specific
	/// </summary>
	StaticLibraryFileExtension { }

	/// <summary>
	/// Gets the dynamic library file extension for the compiler
	/// TODO: This is platform specific
	/// </summary>
	DynamicLibraryFileExtension { }

	/// <summary>
	/// Compile
	/// </summary>
	CreateCompileOperations(options, objectDirectory, targetRootDirectory) {}
}
