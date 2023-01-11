// <copyright file="ICompiler.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

/// <summary>
/// The compiler interface definition
/// </summary>
interface ICompiler
{
	/// <summary>
	/// Gets the unique name for the compiler
	/// </summary>
	string Name { get }

	/// <summary>
	/// Gets the object file extension for the compiler
	/// </summary>
	string ObjectFileExtension { get }

	/// <summary>
	/// Gets the static library file extension for the compiler
	/// TODO: This is platform specific
	/// </summary>
	string StaticLibraryFileExtension { get }

	/// <summary>
	/// Gets the dynamic library file extension for the compiler
	/// TODO: This is platform specific
	/// </summary>
	string DynamicLibraryFileExtension { get }

	/// <summary>
	/// Compile
	/// </summary>
	IList<BuildOperation> CreateCompileOperations(CompileArguments arguments)
}
