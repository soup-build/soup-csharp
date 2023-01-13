// <copyright file="RecipeBuildTaskUnitTests.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

import "soup-test" for SoupTest
import "../../Extension/Tasks/RecipeBuildTask" for RecipeBuildTask
import "../../Utils/Path" for Path
import "../../Test/Assert" for Assert

class RecipeBuildTaskUnitTests {
	construct new() {
	}

	RunTests() {
		System.print("RecipeBuildTaskUnitTests.Build_Executable")
		this.Build_Executable()
	}

	// [Fact]
	Build_Executable() {
		// Setup the input build state
		SoupTest.initialize()
		var activeState = SoupTest.activeState
		var globalState = SoupTest.globalState

		activeState["PlatformLibraries"] = []
		activeState["PlatformIncludePaths"] = []
		activeState["PlatformLibraryPaths"] = []
		activeState["PlatformPreprocessorDefinitions"] = []

		// Setup recipe table
		var buildTable = {}
		globalState["Recipe"] = buildTable
		buildTable["Name"] = "Program"

		// Setup parameters table
		var parametersTable = {}
		globalState["Parameters"] = parametersTable
		parametersTable["TargetDirectory"] = "C:/Target/"
		parametersTable["PackageDirectory"] = "C:/PackageRoot/"
		parametersTable["Compiler"] = "MOCK"
		parametersTable["Flavor"] = "debug"

		RecipeBuildTask.evaluate()

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
