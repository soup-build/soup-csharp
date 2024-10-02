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
		inputFiles = inputFiles + options.References
		var outputFiles = [
			options.OutputAssembly,
			symbolFile,
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

	/// <summary>
	/// Configure the debug switches which will be placed on the compiler command-line.
	/// The matrix of debug type and symbol inputs and the desired results is as follows:
	///
	/// Debug Symbols              DebugType   Desired Results
	///          True               Full        /debug+ /debug:full
	///          True               PdbOnly     /debug+ /debug:PdbOnly
	///          True               None        /debug-
	///          True               Blank       /debug+
	///          False              Full        /debug- /debug:full
	///          False              PdbOnly     /debug- /debug:PdbOnly
	///          False              None        /debug-
	///          False              Blank       /debug-
	///          Blank              Full                /debug:full
	///          Blank              PdbOnly             /debug:PdbOnly
	///          Blank              None        /debug-
	/// Debug:   Blank              Blank       /debug+ //Microsoft.common.targets will set this
	/// Release: Blank              Blank       "Nothing for either switch"
	///
	/// The logic is as follows:
	/// If debugtype is none  set debugtype to empty and debugSymbols to false
	/// If debugType is blank  use the debugsymbols "as is"
	/// If debug type is set, use its value and the debugsymbols value "as is"
	/// </summary>
	// private void ConfigureDebugProperties()
	// {
	// 	// If debug type is set we need to take some action depending on the value. If debugtype is not set
	// 	// We don't need to modify the EmitDebugInformation switch as its value will be used as is.
	// 	if (_store[nameof(DebugType)] != null)
	// 	{
	// 		// If debugtype is none then only show debug- else use the debug type and the debugsymbols as is.
	// 		if (string.Compare((string?)_store[nameof(DebugType)], "none", StringComparison.OrdinalIgnoreCase) == 0)
	// 		{
	// 			_store[nameof(DebugType)] = null
	// 			_store[nameof(EmitDebugInformation)] = false
	// 		}
	// 	}
	// }
}
