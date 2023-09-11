// <copyright file="RecipeNugetPackagesTask.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

import "soup" for Soup, SoupTask
import "Soup.Build.Utils:./ListExtensions" for ListExtensions
import "Soup.Build.Utils:./MapExtensions" for MapExtensions
import "Soup.Build.Utils:./Path" for Path

/// <summary>
/// The recipe build task that knows how to resolve nuget packages
/// </summary>
class RecipeNugetPackagesTask is SoupTask {
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
	] }

	/// <summary>
	/// The Core Execute task
	/// </summary>
	static evaluate() {
		var activeState = Soup.activeState
		var globalState = Soup.globalState

		var recipeTable = globalState["Recipe"]

		// Check for Nuget properties
		if (recipeTable.containsKey("Nuget")) {
			var nuget = recipeTable["Nuget"]
			var build = MapExtensions.EnsureTable(activeState, "Build")

			var linkLibraries = []

			// Resolve all dependency packages
			if (nuget.containsKey("Dependencies")) {
				var nugetDependencies = nuget["Dependencies"]
				if (nugetDependencies.containsKey("Runtime")) {
					for (package in nugetDependencies["Runtime"]) {
						var packageProperties = RecipeNugetPackagesTask.GetPackageProperties(package)
						var targetFramework = RecipeNugetPackagesTask.GetPackageTargetFramework(packageProperties)
						for (value in ListExtensions.ConvertToPathList(targetFramework["Libraries"])) {
							linkLibraries.add(value)
						}
					}
				}
			}

			// Append the nuget package link libraries
			ListExtensions.Append(
				MapExtensions.EnsureList(build, "LinkLibraries"),
				ListExtensions.ConvertFromPathList(linkLibraries))
		}
	}

	static GetPackageTargetFramework(packageProperties) {
		if (!packageProperties.containsKey("TargetFrameworks")) {
			Fiber.abort("Missing Nuget Package TargetFrameworks")
		}
		var targetFrameworks = packageProperties["TargetFrameworks"]

		// Check highest compatible runtime
		if (targetFrameworks.containsKey("net6.0")) {
			return targetFrameworks["net6.0"]
		}

		if (targetFrameworks.containsKey("net5.0")) {
			return targetFrameworks["net5.0"]
		}

		if (targetFrameworks.containsKey("netstandard2.0")) {
			return targetFrameworks["netstandard2.0"]
		}

		Fiber.abort("Missing Nuget Package Compatible target framework")
	}

	static GetPackageProperties(package) {
		var name = package["Name"]
		var version = package["Version"]
		Soup.info("Resolve package %(name) %(version)")

		var nugetProperties = RecipeNugetPackagesTask.GetSDKProperties("Nuget")

		if (!nugetProperties.containsKey("Packages")) {
			Fiber.abort("Missing Nuget Packages in SDK")
		}
		var nugetPackages = nugetProperties["Packages"]

		// Check for the requested package
		if (!nugetPackages.containsKey(name)) {
			Fiber.abort("Missing Nuget Package %(name)")
		}
		var nugetPackageType = nugetPackages[name]

		// Check for the requested package version
		if (!nugetPackageType.containsKey(version)) {
			Fiber.abort("Missing Nuget Package Version %(name) %(version)")
		}
		var nugetPackageVersion = nugetPackageType[version]

		return nugetPackageVersion
	}

	static GetSDKProperties(name) {
		for (sdk in Soup.globalState["SDKs"]) {
			var sdkTable = sdk
			if (sdkTable.containsKey("Name")) {
				if (sdkTable["Name"] == name) {
					return sdkTable["Properties"]
				}
			}
		}

		Fiber.abort("Missing SDK %(name)")
	}
}
