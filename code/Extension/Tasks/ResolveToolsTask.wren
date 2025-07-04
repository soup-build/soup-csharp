﻿// <copyright file="ResolveToolsTask.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

import "soup" for Soup, SoupTask
import "Soup|Build.Utils:./ListExtensions" for ListExtensions
import "Soup|Build.Utils:./MapExtensions" for MapExtensions
import "Soup|Build.Utils:./Path" for Path
import "Soup|Build.Utils:./SemanticVersion" for SemanticVersion

/// <summary>
/// The recipe build task that knows how to build a single recipe
/// </summary>
class ResolveToolsTask is SoupTask {
	/// <summary>
	/// Get the run before list
	/// </summary>
	static runBefore { [
		"BuildTask",
	] }

	/// <summary>
	/// Get the run after list
	/// </summary>
	static runAfter { [
		"InitializeDefaultsTask",
		"RecipeBuildTask",
	] }

	/// <summary>
	/// The Core Execute task
	/// </summary>
	static evaluate() {
		var globalState = Soup.globalState
		var activeState = Soup.activeState

		ResolveToolsTask.LoadDotNet(globalState, activeState)
	}

	static LoadDotNet(globalState, activeState) {
		var build = activeState["Build"]
		var architecture = build["Architecture"]
		var targetFramework = build["TargetFramework"]

		// Check if skip platform includes was specified
		var skipPlatform = false
		if (activeState.containsKey("SkipPlatform")) {
			skipPlatform = activeState["SkipPlatform"]
		}

		// Get the DotNet SDK
		var dotnetSDKProperties = ResolveToolsTask.GetSDKProperties("DotNet", globalState)

		// Get the latest .net sdk
		var sdk = ResolveToolsTask.GetLatestSDK(dotnetSDKProperties)
		var sdkVersion = sdk["Version"]
		var sdkPath = sdk["Path"]

		var targetDotNetVersion = null
		if (targetFramework == "net9.0") {
			targetDotNetVersion = 9
		} else if (targetFramework == "net8.0") {
			targetDotNetVersion = 8
		} else if (targetFramework == "net7.0") {
			targetDotNetVersion = 7
		} else if (targetFramework == "net6.0") {
			targetDotNetVersion = 6
		} else if (targetFramework == "net5.0") {
			targetDotNetVersion = 5
		} else {
			Fiber.abort("Unknown target framework value %(targetFramework).")
		}

		// Get the latest .net targeting pack
		var targetingPack = ResolveToolsTask.GetLatestTargetingPack(
			dotnetSDKProperties, targetDotNetVersion, "Microsoft.NETCore.App.Ref")
		var targetingPackVersion = targetingPack["Version"]
		var targetingPackValue = targetingPack["Value"]
		var targetingPackVersionPath = targetingPackValue["Path"]
		var targetingPackAnalyzers = targetingPackValue["Analyzer"]
		var targetingPackReferences = targetingPackValue["Managed"]

		// Reference the dotnet executable
		var dotNetExecutable = Path.new(dotnetSDKProperties["DotNetExecutable"])

		// Load the roslyn library compiler reference
		var cscToolPath = sdkPath + Path.new("./Roslyn/bincore/csc.dll")

		// Save the build properties
		var roslyn = MapExtensions.EnsureTable(activeState, "Roslyn")
		roslyn["CscToolPath"] = cscToolPath.toString

		var dotnet = MapExtensions.EnsureTable(activeState, "DotNet")
		dotnet["ExecutablePath"] = dotNetExecutable.toString
		dotnet["TargetingPackVersion"] = targetingPack["Version"].toString
		dotnet["TargetingPackPath"] = targetingPackVersionPath.toString

		// Save the platform libraries
		activeState["PlatformLibraries"] = ""
		var linkDependencies = []
		if (build.containsKey("LinkDependencies")) {
			linkDependencies = ListExtensions.ConvertToPathList(build["LinkDependencies"])
		}

		for (value in targetingPackReferences) {
			linkDependencies.add(targetingPackVersionPath + value)
		}
		build["LinkDependencies"] = ListExtensions.ConvertFromPathList(linkDependencies)

		var analyzers = []
		for (value in targetingPackAnalyzers) {
			analyzers.add(targetingPackVersionPath + value)
		}
		build["Analyzers"] = ListExtensions.ConvertFromPathList(analyzers)

		var defineConstants = ResolveToolsTask.BuildDefineConstants(targetDotNetVersion)
		
		ListExtensions.Append(
			MapExtensions.EnsureList(build, "DefineConstants"),
			defineConstants)
	}

	static BuildDefineConstants(targetDotNetVersion) {
		var defineConstants = []
		defineConstants.add("NET")

		// Add the exact target version
		defineConstants.add("NET%(targetDotNetVersion)_0")

		defineConstants.add("NETCOREAPP")

		for (i in [5, 6, 7, 8, 9]) {
			if (targetDotNetVersion >= i) {
				defineConstants.add("NET5_%(i)_OR_GREATER")
			}
		}

		for (i in [0, 1]) {
			if (targetDotNetVersion >= i) {
				defineConstants.add("NETCOREAPP1_%(i)_OR_GREATER")
			}
		}

		for (i in [0, 1, 2]) {
			if (targetDotNetVersion >= i) {
				defineConstants.add("NETCOREAPP2_%(i)_OR_GREATER")
			}
		}

		for (i in [0, 1]) {
			if (targetDotNetVersion >= i) {
				defineConstants.add("NETCOREAPP3_%(i)_OR_GREATER")
			}
		}

		return defineConstants
	}

	static GetSDKProperties(name, globalState) {
		for (sdk in globalState["SDKs"]) {
			if (sdk.containsKey("Name")) {
				var nameValue = sdk["Name"]
				if (nameValue == name) {
					return sdk["Properties"]
				}
			}
		}

		Fiber.abort("Missing SDK %(name)")
	}

	static GetLatestSDK(properties) {
		if (!properties.containsKey("SDKs")) {
			Fiber.abort("Missing DotNet SDK SDKs")
		}

		var sdks = properties["SDKs"]

		var bestVersion
		var bestVersionValue
		var bestVersionPath
		for (sdk in sdks) {
			var sdkVersion = ResolveToolsTask.ParseSemanticVersionWithExtras(sdk.key)
			if (bestVersion is Null || sdkVersion > bestVersion) {
				bestVersion = sdkVersion
				bestVersionValue = sdk.key
				bestVersionPath = Path.new(sdk.value)
			}
		}

		if (bestVersion is Null) {
			Fiber.abort("Missing DotNet SDK SDKs for version %(majorVersion)")
		}

		return { "Version": bestVersionValue, "Path": bestVersionPath } 
	}

	static GetLatestTargetingPack(properties, majorVersion, targetingPackName) {
		if (!properties.containsKey("TargetingPacks")) {
			Fiber.abort("Missing DotNet SDK TargetingPacks")
		}

		var packs = properties["TargetingPacks"]
		if (!packs.containsKey(targetingPackName)) {
			Fiber.abort("Missing DotNet SDK Targeting TargetingPacks Type %(targetingPackName)")
		}

		var targetingPackVersions = packs[targetingPackName]
		var bestVersion
		var bestVersionValue
		for (targetingPack in targetingPackVersions) {
			var targetingPackVersion = ResolveToolsTask.ParseSemanticVersionWithExtras(targetingPack.key)
			if (targetingPackVersion.Major == majorVersion) {
				if (bestVersion is Null || targetingPackVersion > bestVersion) {
					bestVersion = targetingPackVersion
					bestVersionValue = targetingPack.value
				}
			}
		}

		if (bestVersion is Null) {
			Fiber.abort("Missing DotNet SDK TargetingPacks Type %(targetingPackName) for version %(majorVersion)")
		}

		return { "Version": bestVersion, "Value": bestVersionValue } 
	}

	static ParseSemanticVersionWithExtras(value) {
		// Ignore the extras if present
		var versionExtraValues = value.split("-")

		// Parse the integer values
		var stringValues = versionExtraValues[0].split(".")
		if (stringValues.count < 1) {
			Fiber.abort("The version string must have one to three values.")
		}

		var intValues = []
		for (stringValue in stringValues) {
			var intValue = Num.fromString(stringValue)
			if (!(intValue is Null)) {
				intValues.add(intValue)
			} else {
				Fiber.abort("Invalid version string: \"%(value)\"")
			}
		}

		var major = intValues[0]

		var minor = null
		if (intValues.count >= 2) {
			minor = intValues[1]
		}

		var patch = null
		if (intValues.count >= 3) {
			patch = intValues[2]
		}

		return SemanticVersion.new(
			major,
			minor,
			patch)
	}
}
