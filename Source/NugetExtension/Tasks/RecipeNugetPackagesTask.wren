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

			var nugetProperties = RecipeNugetPackagesTask.GetSDKProperties("Nuget")
			var packagesDirectory = Path.new(nugetProperties["PackagesDirectory"])

			// Resolve all dependency packages
			if (nuget.containsKey("Dependencies")) {
				var nugetSDKProperties = RecipeNugetPackagesTask.GetSDKProperties("Nuget")
				var nugetPackagesDirectory = RecipeNugetPackagesTask.GetPackagesDirectory(nugetSDKProperties)
				var nugetDependencies = nuget["Dependencies"]
				if (nugetDependencies.containsKey("Runtime")) {
					for (package in nugetDependencies["Runtime"]) {
						var packageProperties = RecipeNugetPackagesTask.GetPackageProperties(nugetSDKProperties, package)

						var name = package["Name"]
						var version = package["Version"]
						var packageVersionFolder = nugetPackagesDirectory + Path.new("%(name)/%(version)/")

						var targetFrameworks = packageProperties["TargetFrameworks"]
						var currentTargetFramework = RecipeNugetPackagesTask.GetBestFramework(targetFrameworks)
						for (value in ListExtensions.ConvertToPathList(currentTargetFramework["Libraries"])) {
							linkLibraries.add(packageVersionFolder + value)
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

	static GetPackagesDirectory(nugetSDKProperties) {
		if (!nugetSDKProperties.containsKey("PackagesDirectory")) {
			Fiber.abort("Missing Nuget PackagesDirectory in SDK")
		}
		var packagesDirectory = Path.new(nugetSDKProperties["PackagesDirectory"])
		Soup.info("Nuget package directory: %(packagesDirectory)")
		return packagesDirectory
	}

	static GetBestFramework(targetFrameworks) {
		if (targetFrameworks.containsKey("net7.0")) {
			return targetFrameworks["net7.0"]
		} else if (targetFrameworks.containsKey("net6.0")) {
			return targetFrameworks["net6.0"]
		} else if (targetFrameworks.containsKey("net5.0")) {
			return targetFrameworks["net5.0"]
		} else if (targetFrameworks.containsKey("netstandard2.0")) {
			return targetFrameworks["netstandard2.0"]
		} else if (targetFrameworks.containsKey("netstandard1.3")) {
			return targetFrameworks["netstandard1.3"]
		} else {
			Fiber.abort("Missing compatible target framework")
		}
	}

	static GetPackageProperties(nugetSDKProperties, package) {
		var name = package["Name"]
		var version = package["Version"]
		Soup.info("Resolve package %(name) %(version)")

		if (!nugetSDKProperties.containsKey("Packages")) {
			Fiber.abort("Missing Nuget Packages in SDK")
		}
		var nugetPackages = nugetSDKProperties["Packages"]

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
				if (sdkTable["Name"] == name && sdkTable.containsKey("Properties")) {
					var sdkProperties = sdkTable["Properties"]
					return sdkProperties
				}
			}
		}

		Fiber.abort("Missing SDK %(name)")
	}
}
