// <copyright file="ResolveToolsTaskUnitTests.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

import "soup-test" for SoupTest
import "../../Extension/Tasks/ResolveToolsTask" for ResolveToolsTask
import "Soup.Build.Utils:./Path" for Path
import "../../Test/Assert" for Assert

class ResolveToolsTaskUnitTests {
	construct new() {
	}

	RunTests() {
		System.print("ResolveToolsTaskUnitTests.Execute")
		this.Execute()
	}

	// [Fact]
	Execute() {
		// Setup the input build state
		SoupTest.initialize()
		var activeState = SoupTest.activeState
		var globalState = SoupTest.globalState

		// Set the sdks
		var sdks = []
		sdks.add(
			{
				"Name": "Roslyn",
				"Properties": { "ToolsRoot": "C:/Roslyn/ToolsRoot/", },
			})
		sdks.add(
			{
				"Name": "DotNet",
				"Properties": { "RuntimeVersion": "6.0.12", "RootPath": "C:/dotnet/", },
			})

		// Setup parameters table
		var parametersTable = {}
		globalState["Parameters"] = parametersTable
		parametersTable["SDKs"] = sdks
		parametersTable["System"] = "win32"
		parametersTable["Architecture"] = "x64"

		// Setup build table
		var buildTable = {}
		activeState["Build"] = buildTable

		ResolveToolsTask.evaluate()

		// Verify expected logs
		Assert.ListEqual(
			[],
			SoupTest.logs)

		// Verify build state
		var expectedBuildOperations = []

		Assert.ListEqual(
			expectedBuildOperations,
			SoupTest.operations)
	}
}
