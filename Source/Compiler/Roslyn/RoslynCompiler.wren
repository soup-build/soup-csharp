// <copyright file="RoslynCompiler.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

import "./CommandLineBuilder" for CommandLineBuilder
import "./RoslynArgumentBuilder" for RoslynArgumentBuilder
import "mwasplund|Soup.CSharp.Compiler:./ICompiler" for ICompiler
import "mwasplund|Soup.Build.Utils:./BuildOperation" for BuildOperation
import "mwasplund|Soup.Build.Utils:./SharedOperations" for SharedOperations
import "mwasplund|Soup.Build.Utils:./Path" for Path

/// <summary>
/// The Clang compiler implementation
/// </summary>
class RoslynCompiler is ICompiler {
	construct new(dotnetExecutable, compilerLibrary) {
		_dotnetExecutable = dotnetExecutable
		_compilerLibrary = compilerLibrary
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
	CreateCompileOperations(options) {
		var operations = []

		// Write the shared arguments to the response file
		var responseFile = arguments.ObjectDirectory + Path.new("CompileArguments.rsp")
		var responseFileArgumentBuilder = CommandLineBuilder.new()
		RoslynArgumentBuilder.BuildResponseFileArguments(options, responseFileArgumentBuilder)

		var writeSharedArgumentsOperation = SharedOperations.CreateWriteFileOperation(
			arguments.TargetRootDirectory,
			responseFile,
			sharedCommandArguments.toString)
		operations.add(writeSharedArgumentsOperation)

		var symbolFile = Path.new(arguments.Target.toString)
		symbolFile.SetFileExtension("pdb")

		var targetResponseFile = arguments.TargetRootDirectory + responseFile

		// Build up the input/output sets
		var inputFiles = []
		inputFiles.add(_compilerLibrary)
		inputFiles.add(targetResponseFile)
		inputFiles = inputFiles + arguments.SourceFiles
		inputFiles = inputFiles + arguments.ReferenceLibraries
		var outputFiles = [
			arguments.TargetRootDirectory + arguments.Target,
			arguments.TargetRootDirectory + symbolFile,
		]

		var commandLineArgumentBuilder = CommandLineBuilder.new()
		commandLineArgumentBuilder.Append("exec")
		commandLineArgumentBuilder.Append("%(_compilerLibrary)")
		commandLineArgumentBuilder.Append("@%(targetResponseFile)")
		RoslynArgumentBuilder.BuildCommandLineArguments(commandLineArgumentBuilder)

		// Generate the compile build operation
		var commandArguments = commandLineArgumentBuilder.CommandArguments
		var buildOperation = BuildOperation.new(
			"Compile - %(arguments.Target)",
			arguments.SourceRootDirectory,
			_dotnetExecutable,
			commandArguments,
			inputFiles,
			outputFiles)
		operations.add(buildOperation)

		return operations
	}
}
