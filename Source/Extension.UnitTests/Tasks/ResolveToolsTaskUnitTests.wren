// <copyright file="ResolveToolsTaskUnitTests.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

class ResolveToolsTaskUnitTests {

	// [Fact]
	Execute() {
		// Setup the input build state
		SoupTest.initialize()
		var activeState = SoupTest.activeState
		var globalState = SoupTest.globalState

		// Set the sdks
		var sdks = [
		sdks.add(new Value({}
		{
			{ "Name", new Value("Roslyn") },
			{
				"Properties",
				new Value({}
				{
					{ "ToolsRoot", new Value("C:/Roslyn/ToolsRoot/") }
				})
			},
		}))

		// Setup parameters table
		var parametersTable = {}
		state.add("Parameters", new Value(parametersTable))
		parametersTable.add("SDKs", new Value(sdks))
		parametersTable.add("System", new Value("win32"))
		parametersTable.add("Architecture", new Value("x64"))

		// Setup build table
		var buildTable = {}
		state.add("Build", new Value(buildTable))

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
