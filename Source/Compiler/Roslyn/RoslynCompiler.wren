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
	CreateCompileOperations(options, objectDirectory, targetRootDirectory) {
		var operations = []

		// Write the shared arguments to the response file
		var responseFile = objectDirectory + Path.new("CompileArguments.rsp")
		var responseFileBuilder = CommandLineBuilder.new()
		var agumentBuilder = RoslynArgumentBuilder.new()
		agumentBuilder.BuildResponseFileArguments(options, responseFileBuilder)

		var writeSharedArgumentsOperation = SharedOperations.CreateWriteFileOperation(
			targetRootDirectory,
			responseFile,
			responseFileBuilder.toString)
		operations.add(writeSharedArgumentsOperation)

		var symbolFile = Path.new(options.OutputAssembly.toString)
		symbolFile.SetFileExtension("pdb")

		var targetResponseFile = targetRootDirectory + responseFile

		// Build up the input/output sets
		var inputFiles = []
		inputFiles.add(_compilerLibrary)
		inputFiles.add(targetResponseFile)
		inputFiles = inputFiles + options.Sources
		inputFiles = inputFiles + options.ReferenceLibraries
		var outputFiles = [
			targetRootDirectory + options.OutputAssembly,
			targetRootDirectory + symbolFile,
		]

		var commandLineBuilder = CommandLineBuilder.new()
		commandLineBuilder.Append("exec")
		commandLineBuilder.Append("%(_compilerLibrary)")
		commandLineBuilder.Append("@%(targetResponseFile)")
		agumentBuilder.BuildCommandLineArguments(options, commandLineBuilder)

		// Generate the compile build operation
		var commandArguments = commandLineBuilder.CommandArguments
		var buildOperation = BuildOperation.new(
			"Compile - %(options.OutputAssembly)",
			options.SourceRootDirectory,
			_dotnetExecutable,
			commandArguments,
			inputFiles,
			outputFiles)
		operations.add(buildOperation)

		return operations
	}
}
