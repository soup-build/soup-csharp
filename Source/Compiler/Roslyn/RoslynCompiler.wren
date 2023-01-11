// <copyright file="RoslynCompiler.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

/// <summary>
/// The Clang compiler implementation
/// </summary>
class RoslynCompiler is ICompiler {
	Compiler(compilerExecutable) {
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
		var sharedCommandArguments = ArgumentBuilder.BuildSharedCompilerArguments(arguments)
		var writeSharedArgumentsOperation = SharedOperations.CreateWriteFileOperation(
			arguments.TargetRootDirectory,
			responseFile,
			string.Join(" ", sharedCommandArguments))
		operations.add(writeSharedArgumentsOperation)

		var symbolFile = Path.new(arguments.Target.toString)
		symbolFile.SetFileExtension("pdb")

		var targetResponseFile = arguments.TargetRootDirectory + responseFile

		// Build up the input/output sets
		var inputFiles = []
		inputFiles.add(targetResponseFile)
		inputFiles.AddRange(arguments.SourceFiles)
		inputFiles.AddRange(arguments.ReferenceLibraries)
		var outputFiles = [
			arguments.TargetRootDirectory + arguments.Target,
			arguments.TargetRootDirectory + symbolFile,
		]

		// Generate the compile build operation
		var uniqueCommandArguments = ArgumentBuilder.BuildUniqueCompilerArguments()
		var commandArguments = "@%(targetResponseFile) %(uniqueCommandArguments)"
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
