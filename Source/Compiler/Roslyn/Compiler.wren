// <copyright file="Compiler.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

/// <summary>
/// The Clang compiler implementation
/// </summary>
class Compiler is ICompiler {
	Compiler(Path compilerExecutable)
	{
		_compilerExecutable = compilerExecutable
	}

	/// <summary>
	/// Gets the unique name for the compiler
	/// </summary>
	string Name => "Roslyn"

	/// <summary>
	/// Gets the object file extension for the compiler
	/// </summary>
	string ObjectFileExtension => "obj"

	/// <summary>
	/// Gets the static library file extension for the compiler
	/// TODO: This is platform specific
	/// </summary>
	string StaticLibraryFileExtension => "lib"

	/// <summary>
	/// Gets the dynamic library file extension for the compiler
	/// TODO: This is platform specific
	/// </summary>
	string DynamicLibraryFileExtension => "dll"

	/// <summary>
	/// Compile
	/// </summary>
	IList<BuildOperation> CreateCompileOperations(
		CompileArguments arguments)
	{
		var operations = new List<BuildOperation>()

		// Write the shared arguments to the response file
		var responseFile = arguments.ObjectDirectory + new Path("CompileArguments.rsp")
		var sharedCommandArguments = ArgumentBuilder.BuildSharedCompilerArguments(arguments)
		var writeSharedArgumentsOperation = SharedOperations.CreateWriteFileOperation(
			arguments.TargetRootDirectory,
			responseFile,
			string.Join(" ", sharedCommandArguments))
		operations.Add(writeSharedArgumentsOperation)

		var symbolFile = new Path(arguments.Target.ToString())
		symbolFile.SetFileExtension("pdb")

		var targetResponseFile = arguments.TargetRootDirectory + responseFile

		// Build up the input/output sets
		var inputFiles = new List<Path>()
		inputFiles.Add(targetResponseFile)
		inputFiles.AddRange(arguments.SourceFiles)
		inputFiles.AddRange(arguments.ReferenceLibraries)
		var outputFiles = new List<Path>()
		{
			arguments.TargetRootDirectory + arguments.Target,
			arguments.TargetRootDirectory + symbolFile,
		}

		// Generate the compile build operation
		var uniqueCommandArguments = ArgumentBuilder.BuildUniqueCompilerArguments()
		var commandArguments = $"@{targetResponseFile} {string.Join(" ", uniqueCommandArguments)}"
		var buildOperation = new BuildOperation(
			$"Compile - {arguments.Target}",
			arguments.SourceRootDirectory,
			_compilerExecutable,
			commandArguments,
			inputFiles,
			outputFiles)
		operations.Add(buildOperation)

		return operations
	}

	private Path _compilerExecutable
}
