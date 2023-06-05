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
		System.print("RecipeNugetPackagesTaskUnitTests.Build_Executable")
		this.Build_Executable()
	}

	// [Fact]
	Build_Executable() {
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

		// TODO: Verify output build state
	}
}
