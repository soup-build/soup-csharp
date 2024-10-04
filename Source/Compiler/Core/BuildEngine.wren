// <copyright file="BuildEngine.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

import "./BuildResult" for BuildResult
import "./BuildOptions" for BuildTargetType, BuildNullableState
import "./CompileOptions" for CompileOptions, NullableState
import "./ManagedCompileOptions" for LinkTarget
import "mwasplund|Soup.Build.Utils:./SharedOperations" for SharedOperations
import "mwasplund|Soup.Build.Utils:./Path" for Path

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
	Execute(options) {
		var result = BuildResult.new()

		// Ensure the output directories exists as the first step
		var referenceDirectory = options.BinaryDirectory + Path.new("ref/")
		result.BuildOperations.add(
			SharedOperations.CreateCreateDirectoryOperation(
				options.TargetRootDirectory,
				options.ObjectDirectory))
		result.BuildOperations.add(
			SharedOperations.CreateCreateDirectoryOperation(
				options.TargetRootDirectory,
				options.BinaryDirectory))
		result.BuildOperations.add(
			SharedOperations.CreateCreateDirectoryOperation(
				options.TargetRootDirectory,
				referenceDirectory))

		// Perform the core compilation of the source files
		this.CoreCompile(options, referenceDirectory, result)

		// Copy previous runtime dependencies after linking has completed
		this.CopyRuntimeDependencies(options, result)

		this.GenerateBuildRuntimeConfigurationFiles(options, result)

		return result
	}

	/// <summary>
	/// Compile the source files
	/// </summary>
	CoreCompile(options, referenceDirectory, result) {
		// Ensure there are actually files to build
		if (options.SourceFiles.count != 0) {
			var targetFile
			var referenceTargetFile
			var targetType
			if (options.TargetType == BuildTargetType.Library) {
				targetType = LinkTarget.Library
				targetFile = options.TargetRootDirectory + options.BinaryDirectory +
					Path.new(options.TargetName + "." + _compiler.DynamicLibraryFileExtension)
				referenceTargetFile = options.TargetRootDirectory + referenceDirectory +
					Path.new(options.TargetName + "." + _compiler.DynamicLibraryFileExtension)

				// Add the DLL as a runtime dependency
				result.RuntimeDependencies.add(targetFile)

				// Link against the reference target
				result.LinkDependencies.add(referenceTargetFile)
			} else if (options.TargetType == BuildTargetType.Executable) {
				targetType = LinkTarget.Executable
				targetFile = options.TargetRootDirectory + options.BinaryDirectory +
					Path.new(options.TargetName + "." + _compiler.DynamicLibraryFileExtension)
				referenceTargetFile = options.TargetRootDirectory + referenceDirectory +
					Path.new(options.TargetName + "." + _compiler.DynamicLibraryFileExtension)

				// Add the Executable as a runtime dependency
				result.RuntimeDependencies.add(targetFile)

				// All link dependencies stop here.
			} else {
				Fiber.abort("Unknown build target type.")
			}

			// Convert the nullable state
			var nullableState
			if (options.NullableState == BuildNullableState.Disabled) {
				nullableState = NullableState.Disabled
			} else if (options.NullableState == BuildNullableState.Enabled) {
				nullableState = NullableState.Enabled
			} else if (options.NullableState == BuildNullableState.Warnings) {
				nullableState = NullableState.Warnings
			} else if (options.NullableState == BuildNullableState.Annotations) {
				nullableState = NullableState.Annotations
			} else {
				Fiber.abort("Unknown Nullable State")
			}

			// Setup the shared properties
			var compileOptions = CompileOptions.new()
			compileOptions.OutputAssembly = targetFile
			compileOptions.OutputRefAssembly = referenceTargetFile
			compileOptions.TargetType = targetType
			compileOptions.SourceRootDirectory = options.SourceRootDirectory
			compileOptions.DefineConstants = options.DefineConstants
			compileOptions.GenerateSourceDebugInfo = options.GenerateSourceDebugInfo
			compileOptions.TreatWarningsAsErrors = options.TreatWarningsAsErrors
			compileOptions.DisabledWarnings = options.DisabledWarnings
			compileOptions.EnabledWarnings = options.EnabledWarnings
			compileOptions.NullableState = nullableState
			compileOptions.CustomProperties = options.CustomProperties
			compileOptions.References = options.LinkDependencies
			compileOptions.Analyzers = options.Analyzers

			for (sourceFile in options.SourceFiles) {
				compileOptions.Sources.add(options.SourceRootDirectory + sourceFile)
			}

			// Compile all source files as a single call
			var compileOperations = _compiler.CreateCompileOperations(
				compileOptions, options.ObjectDirectory, options.TargetRootDirectory)
			for (operation in compileOperations) {
				result.BuildOperations.add(operation)
			}

			result.TargetFile = targetFile
		}
	}

	/// <summary>
	/// Copy runtime dependencies
	/// </summary>
	CopyRuntimeDependencies(options, result) {
		if (options.TargetType == BuildTargetType.Executable ||
			options.TargetType == BuildTargetType.Library) {
			// TODO: Allow build libraries to copy dependencies with a flag
			// for now we always copy the dlls so the folder is ready to load dependencies
			for (source in options.RuntimeDependencies) {
				var target = options.BinaryDirectory + Path.new(source.GetFileName())
				var operation = SharedOperations.CreateCopyFileOperation(
					options.TargetRootDirectory,
					source,
					target)
				result.BuildOperations.add(operation)
			}
		}

		if (options.TargetType != BuildTargetType.Executable) {
			// Pass along all runtime dependencies in their original location
			for (source in options.RuntimeDependencies) {
				result.RuntimeDependencies.add(source)
			}
		}
	}

	/// <summary>
	/// Generate Build Runtime Configuration Files
	/// </summary>
	GenerateBuildRuntimeConfigurationFiles(options, result) {
		if (options.TargetType == BuildTargetType.Executable) {
			// Generate the runtime configuration files
			var runtimeConfigFile = options.BinaryDirectory + Path.new("%(options.TargetName).runtimeconfig.json")
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
				options.TargetRootDirectory,
				runtimeConfigFile,
				content)
			result.BuildOperations.add(writeRuntimeConfigFile)
		}
	}
}
