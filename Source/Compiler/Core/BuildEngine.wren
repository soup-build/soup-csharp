// <copyright file="BuildEngine.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

/// <summary>
/// The build engine
/// </summary>
class BuildEngine {
	construct new(ICompiler compiler) {
		_compiler = compiler
	}

	/// <summary>
	/// Generate the required build operations for the requested build
	/// </summary>
	Execute(arguments) {
		var result = BuildResult.new()

		// Ensure the output directories exists as the first step
		var referenceDirectory = arguments.BinaryDirectory + Path.new("ref/")
		result.BuildOperations.add(
			SharedOperations.CreateCreateDirectoryOperation(
				arguments.TargetRootDirectory,
				arguments.ObjectDirectory))
		result.BuildOperations.add(
			SharedOperations.CreateCreateDirectoryOperation(
				arguments.TargetRootDirectory,
				arguments.BinaryDirectory))
		result.BuildOperations.add(
			SharedOperations.CreateCreateDirectoryOperation(
				arguments.TargetRootDirectory,
				referenceDirectory))

		// Perform the core compilation of the source files
		CoreCompile(arguments, referenceDirectory, result)

		// Copy previous runtime dependencies after linking has completed
		CopyRuntimeDependencies(arguments, result)

		GenerateBuildRuntimeConfigurationFiles(arguments, result)

		return result
	}

	/// <summary>
	/// Compile the source files
	/// </summary>
	CoreCompile(arguments, referenceDirectory, result) {
		// Ensure there are actually files to build
		if (arguments.SourceFiles.count != 0) {
			Path targetFile
			Path referenceTargetFile
			LinkTarget targetType
			switch (arguments.TargetType)
			{
				case BuildTargetType.Library:
					targetType = LinkTarget.Library
					targetFile =
						arguments.BinaryDirectory +
						Path.new(arguments.TargetName + "." + _compiler.DynamicLibraryFileExtension)
					referenceTargetFile =
						referenceDirectory +
						Path.new(arguments.TargetName + "." + _compiler.DynamicLibraryFileExtension)

					// Add the DLL as a runtime dependency
					result.RuntimeDependencies.add(arguments.TargetRootDirectory + targetFile)

					// Link against the reference target
					result.LinkDependencies.add(arguments.TargetRootDirectory + referenceTargetFile)

					break
				case BuildTargetType.Executable:
					targetType = LinkTarget.Executable
					targetFile =
						arguments.BinaryDirectory +
						Path.new(arguments.TargetName + "." + _compiler.DynamicLibraryFileExtension)
					referenceTargetFile =
						referenceDirectory +
						Path.new(arguments.TargetName + "." + _compiler.DynamicLibraryFileExtension)

					// Add the Executable as a runtime dependency
					result.RuntimeDependencies.add(arguments.TargetRootDirectory + targetFile)

					// All link dependencies stop here.

					break
				default:
					Fiber.abort("Unknown build target type.")
			}

			// Convert the nullable state
			NullableState nullableState
			switch (arguments.NullableState) {
				case BuildNullableState.Disabled:
					nullableState = NullableState.Disabled
					break
				case BuildNullableState.Enabled:
					nullableState = NullableState.Enabled
					break
				case BuildNullableState.Warnings:
					nullableState = NullableState.Warnings
					break
				case BuildNullableState.Annotations:
					nullableState = NullableState.Annotations
					break
				default:
					Fiber.abort("Unknown Nullable State")
			}

			// Setup the shared properties
			var compileArguments = CompileArguments.new()
			compileArguments.Target = targetFile
			compileArguments.ReferenceTarget = referenceTargetFile
			compileArguments.TargetType = targetType
			compileArguments.SourceRootDirectory = arguments.SourceRootDirectory
			compileArguments.TargetRootDirectory = arguments.TargetRootDirectory
			compileArguments.ObjectDirectory = arguments.ObjectDirectory
			compileArguments.SourceFiles = arguments.SourceFiles
			compileArguments.PreprocessorDefinitions = arguments.PreprocessorDefinitions
			compileArguments.GenerateSourceDebugInfo = arguments.GenerateSourceDebugInfo
			compileArguments.EnableWarningsAsErrors = arguments.EnableWarningsAsErrors
			compileArguments.DisabledWarnings = arguments.DisabledWarnings
			compileArguments.EnabledWarnings = arguments.EnabledWarnings
			compileArguments.NullableState = nullableState
			compileArguments.CustomProperties = arguments.CustomProperties
			compileArguments.ReferenceLibraries = arguments.LinkDependencies

			// Compile all source files as a single call
			var compileOperations = _compiler.CreateCompileOperations(compileArguments)
			for (operation in compileOperations) {
				result.BuildOperations.add(operation)
			}

			result.TargetFile = arguments.TargetRootDirectory + targetFile
		}
	}

	/// <summary>
	/// Copy runtime dependencies
	/// </summary>
	CopyRuntimeDependencies(arguments, result) {
		if (arguments.TargetType == BuildTargetType.Executable ||
			arguments.TargetType == BuildTargetType.Library) {
			// TODO: Allow build libraries to copy dependencies with a flag
			// for now we always copy the dlls so the folder is ready to load dependencies
			for (source in arguments.RuntimeDependencies) {
				var target = arguments.BinaryDirectory + Path.new(source.GetFileName())
				var operation = SharedOperations.CreateCopyFileOperation(
					arguments.TargetRootDirectory,
					source,
					target)
				result.BuildOperations.add(operation)
			}
		}

		if (arguments.TargetType != BuildTargetType.Executable) {
			// Pass along all runtime dependencies in their original location
			for (source in arguments.RuntimeDependencies) {
				result.RuntimeDependencies.add(source)
			}
		}
	}

	/// <summary>
	/// Generate Build Runtime Configuration Files
	/// </summary>
	GenerateBuildRuntimeConfigurationFiles(arguments, result) {
		if (arguments.TargetType == BuildTargetType.Executable) {
			// Generate the runtime configuration files
			var runtimeConfigFile = arguments.BinaryDirectory + Path.new("%(arguments.TargetName).runtimeconfig.json")
			var content =
"{
	""runtimeOptions"": {
		""tfm"": ""net6.0"",
		""framework"": {
			""name"": ""Microsoft.NETCore.App"",
			""version"": ""6.0.0""
		},
		""configProperties"": {
			""System.Reflection.Metadata.MetadataUpdater.IsSupported"": false
		}
	}
}"
			var writeRuntimeConfigFile = SharedOperations.CreateWriteFileOperation(
				arguments.TargetRootDirectory,
				runtimeConfigFile,
				content)
			result.BuildOperations.add(writeRuntimeConfigFile)
		}
	}
}
