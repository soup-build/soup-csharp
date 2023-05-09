// <copyright file="RoslynCompiler.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

import "./RoslynArgumentBuilder" for RoslynArgumentBuilder
import "Soup.CSharp.Compiler:./ICompiler" for ICompiler
import "Soup.Build.Utils:./BuildOperation" for BuildOperation
import "Soup.Build.Utils:./SharedOperations" for SharedOperations
import "Soup.Build.Utils:./Path" for Path

/// <summary>
/// The Clang compiler implementation
/// </summary>
class RoslynCompiler is ICompiler {
	construct new(compilerExecutable) {
		_compilerExecutable = compilerExecutable
	}

	/// <summary>
	/// Gets the unique name for the compiler
	/// </summary>
	Name { "Roslyn" }

	/// <summary>
	/// Gets the object file extension for the compiler
	/// </summary>
	ObjectFileExtension { "obj" }

	/// <summary>
	/// Gets the static library file extension for the compiler
	/// TODO: This is platform specific
	/// </summary>
	StaticLibraryFileExtension { "lib" }

	/// <summary>
	/// Gets the dynamic library file extension for the compiler
	/// TODO: This is platform specific
	/// </summary>
	DynamicLibraryFileExtension { "dll" }

	/// <summary>
	/// Compile
	/// </summary>
	CreateCompileOperations(arguments) {
		var operations = []

		// Write the shared arguments to the response file
		var responseFile = arguments.ObjectDirectory + Path.new("CompileArguments.rsp")
		var sharedCommandArguments = RoslynArgumentBuilder.BuildSharedCompilerArguments(arguments)
		var writeSharedArgumentsOperation = SharedOperations.CreateWriteFileOperation(
			arguments.TargetRootDirectory,
			responseFile,
			sharedCommandArguments.join(" "))
		operations.add(writeSharedArgumentsOperation)

		var symbolFile = Path.new(arguments.Target.toString)
		symbolFile.SetFileExtension("pdb")

		var targetResponseFile = arguments.TargetRootDirectory + responseFile

		// Build up the input/output sets
		var inputFiles = []
		inputFiles.add(targetResponseFile)
		inputFiles = inputFiles + arguments.SourceFiles
		inputFiles = inputFiles + arguments.ReferenceLibraries
		var outputFiles = [
			arguments.TargetRootDirectory + arguments.Target,
			arguments.TargetRootDirectory + symbolFile,
		]

		// Generate the compile build operation
		var commandArguments = RoslynArgumentBuilder.BuildUniqueCompilerArguments()
		commandArguments.insert(0, "@%(targetResponseFile)")
		var buildOperation = BuildOperation.new(
			"Compile - %(arguments.Target)",
			arguments.SourceRootDirectory,
			_compilerExecutable,
			commandArguments,
			inputFiles,
			outputFiles)
		operations.add(buildOperation)

		return operations
	}
}
