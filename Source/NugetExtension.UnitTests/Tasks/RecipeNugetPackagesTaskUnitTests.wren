// <copyright file="RecipeNugetPackagesTaskUnitTests.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

import "soup-test" for SoupTest
import "../../NugetExtension/Tasks/RecipeNugetPackagesTask" for RecipeNugetPackagesTask
import "Soup.Build.Utils:./Path" for Path
import "../../Test/Assert" for Assert

class RecipeNugetPackagesTaskUnitTests {
	construct new() {
	}

	RunTests() {
		System.print("RecipeNugetPackagesTaskUnitTests.Evaluate_Empty")
		this.Evaluate_Empty()
		System.print("RecipeNugetPackagesTaskUnitTests.Evaluate_Single")
		this.Evaluate_Single()
	}

	// [Fact]
	Evaluate_Empty() {
		// Setup the input build state
		SoupTest.initialize()
		var activeState = SoupTest.activeState
		var globalState = SoupTest.globalState

		// Setup context table
		var contextTable = {}
		globalState["Context"] = contextTable
		contextTable["TargetDirectory"] = "/(TARGET)/"
		contextTable["PackageDirectory"] = "/(PACKAGE)/"

		// Setup build table
		var buildTable = {}
		activeState["Build"] = buildTable
		buildTable["Compiler"] = "MOCK"
		buildTable["Flavor"] = "Debug"

		// Setup recipe table
		var recipeTable = {}
		globalState["Recipe"] = recipeTable
		recipeTable["Name"] = "Program"

		RecipeNugetPackagesTask.evaluate()

		// Verify expected logs
		Assert.ListEqual(
			[],
			SoupTest.logs)

		// Verify build state
		var expectedBuildOperations = []

		Assert.ListEqual(
			expectedBuildOperations,
			SoupTest.operations)

		// Verify output build state
		var expectedActiveState = {
			"Build": {
				"Compiler": "MOCK",
				"Flavor": "Debug"
			}
		}
		Assert.MapEqual(
			expectedActiveState,
			SoupTest.activeState)
	}

	// [Fact]
	Evaluate_Single() {
		// Setup the input build state
		SoupTest.initialize()
		var activeState = SoupTest.activeState
		var globalState = SoupTest.globalState

		// Setup context table
		var contextTable = {}
		globalState["Context"] = contextTable
		contextTable["TargetDirectory"] = "/(TARGET)/"
		contextTable["PackageDirectory"] = "/(PACKAGE)/"

		// Setup build table
		var buildTable = {}
		activeState["Build"] = buildTable
		buildTable["Compiler"] = "MOCK"
		buildTable["Flavor"] = "Debug"

		// Setup SDKs table
		globalState["SDKs"] = [
			{
				"Name": "Nuget",
				"SourceDirectories": [
					"C:/Users/me/.nuget/packages"
				],
				"Properties": {
					"PackagesDirectory": "C:/Users/me/.nuget/packages",
					"Packages": {
						"TestPackage1": {
							"1.2.3": {
								"TargetFrameworks": {
									"netstandard2.0": {
										"Libraries": [
											"./lib/netstandard2.0/TestPackage1.dll"
										]
									}
								}
							}
						}
					}
				}
			}
		]

		// Setup recipe table
		var recipeTable = {}
		globalState["Recipe"] = recipeTable
		recipeTable["Name"] = "Program"

		// Setup nuget table
		recipeTable["Nuget"] = {
			"Dependencies": {
				"Runtime": [
					{ "Name": "TestPackage1", "Version": "1.2.3" }
				]
			}
		}

		RecipeNugetPackagesTask.evaluate()

		// Verify expected logs
		Assert.ListEqual(
			[
				"INFO: Resolve package TestPackage1 1.2.3",
			],
			SoupTest.logs)

		// Verify build state
		var expectedBuildOperations = []

		Assert.ListEqual(
			expectedBuildOperations,
			SoupTest.operations)

		// Verify output build state
		var expectedActiveState = {
			"Build": {
				"LinkLibraries": [
					"C:/Users/me/.nuget/packages/TestPackage1/1.2.3/lib/netstandard2.0/TestPackage1.dll"
				],
				"Compiler": "MOCK",
				"Flavor": "Debug"
			}
		}
		Assert.MapEqual(
			expectedActiveState,
			SoupTest.activeState)
	}
}
