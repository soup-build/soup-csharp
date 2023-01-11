// <copyright file="BuildEngine.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

import "./BuildResult" for BuildResult
import "./BuildArguments" for BuildTargetType, BuildNullableState
import "./CompileArguments" for CompileArguments, LinkTarget, NullableState
import "../../Utils/SharedOperations" for SharedOperations
import "../../Utils/Path" for Path

/// <summary>
/// The build engine
/// </summary>
class BuildEngine {
	construct new(compiler) {
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
		this.CoreCompile(arguments, referenceDirectory, result)

		// Copy previous runtime dependencies after linking has completed
		this.CopyRuntimeDependencies(arguments, result)

		this.GenerateBuildRuntimeConfigurationFiles(arguments, result)

		return result
	}

	/// <summary>
	/// Compile the source files
	/// </summary>
	CoreCompile(arguments, referenceDirectory, result) {
		// Ensure there are actually files to build
		if (arguments.SourceFiles.count != 0) {
			var targetFile
			var referenceTargetFile
			var targetType
			if (arguments.TargetType == BuildTargetType.Library) {
				targetType = LinkTarget.Library
				targetFile = arguments.BinaryDirectory +
					Path.new(arguments.TargetName + "." + _compiler.DynamicLibraryFileExtension)
				referenceTargetFile = referenceDirectory +
					Path.new(arguments.TargetName + "." + _compiler.DynamicLibraryFileExtension)

				// Add the DLL as a runtime dependency
				result.RuntimeDependencies.add(arguments.TargetRootDirectory + targetFile)

				// Link against the reference target
				result.LinkDependencies.add(arguments.TargetRootDirectory + referenceTargetFile)
			} else if (arguments.TargetType == BuildTargetType.Executable) {
				targetType = LinkTarget.Executable
				targetFile = arguments.BinaryDirectory +
					Path.new(arguments.TargetName + "." + _compiler.DynamicLibraryFileExtension)
				referenceTargetFile = referenceDirectory +
					Path.new(arguments.TargetName + "." + _compiler.DynamicLibraryFileExtension)

				// Add the Executable as a runtime dependency
				result.RuntimeDependencies.add(arguments.TargetRootDirectory + targetFile)

				// All link dependencies stop here.
			} else {
				Fiber.abort("Unknown build target type.")
			}

			// Convert the nullable state
			var nullableState
			if (arguments.NullableState == BuildNullableState.Disabled) {
				nullableState = NullableState.Disabled
			} else if (arguments.NullableState == BuildNullableState.Enabled) {
				nullableState = NullableState.Enabled
			} else if (arguments.NullableState == BuildNullableState.Warnings) {
				nullableState = NullableState.Warnings
			} else if (arguments.NullableState == BuildNullableState.Annotations) {
				nullableState = NullableState.Annotations
			} else {
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
			var content = "{
	\"runtimeOptions\": {
		\"tfm\": \"net6.0\",
		\"framework\": {
			\"name\": \"Microsoft.NETCore.App\",
			\"version\": \"6.0.0\"
		},
		\"configProperties\": {
			\"System.Reflection.Metadata.MetadataUpdater.IsSupported\": false
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
