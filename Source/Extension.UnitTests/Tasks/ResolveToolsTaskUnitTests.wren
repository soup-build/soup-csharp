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
		globalState["SDKs"] = sdks
		sdks.add(
			{
				"Name": "DotNet",
				"Properties": {
					"DotNetExecutable": "C:/Program Files/dotnet/dotnet.exe",
					"SDKs": {
						"7.0.304": "C:/Program Files/dotnet/sdk",
						"7.0.400-preview.23274.1": "C:/Program Files/dotnet/sdk"
					},
					"Runtimes": {
						"Microsoft.AspNetCore.App": {
							"6.0.18": "C:/Program Files/dotnet/shared/Microsoft.AspNetCore.App",
							"7.0.7": "C:/Program Files/dotnet/shared/Microsoft.AspNetCore.App"
						},
						"Microsoft.NETCore.App": {
							"6.0.18": "C:/Program Files/dotnet/shared/Microsoft.NETCore.App",
							"7.0.7": "C:/Program Files/dotnet/shared/Microsoft.NETCore.App"
						},
						"Microsoft.WindowsDesktop.App": {
							"6.0.18": "C:/Program Files/dotnet/shared/Microsoft.WindowsDesktop.App",
							"7.0.7": "C:/Program Files/dotnet/shared/Microsoft.WindowsDesktop.App"
						},
					},
					"TargetingPacks": {
						"Microsoft.NETCore.App.Ref": {
							"6.0.18": "C:/Program Files/dotnet/pack/Microsoft.NETCore.App.Ref",
							"7.0.7": "C:/Program Files/dotnet/pack/Microsoft.NETCore.App.Ref"
						},
					},
				},
			})

		// Setup parameters table
		var parametersTable = {}
		globalState["Parameters"] = parametersTable
		parametersTable["Architecture"] = "AnyCPU"

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
