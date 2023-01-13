// <copyright file="RecipeBuildTaskUnitTests.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

class RecipeBuildTaskUnitTests {
	// [Fact]
	Build_Executable() {
		// Setup the input build state
		SoupTest.initialize()
		var activeState = SoupTest.activeState
		var globalState = SoupTest.globalState

		activeState.add("PlatformLibraries", new Value([))
		activeState.add("PlatformIncludePaths", new Value([))
		activeState.add("PlatformLibraryPaths", new Value([))
		activeState.add("PlatformPreprocessorDefinitions", new Value([))

		// Setup recipe table
		var buildTable = {}
		globalState.add("Recipe", new Value(buildTable))
		buildTable.add("Name", new Value("Program"))

		// Setup parameters table
		var parametersTable = {}
		globalState.add("Parameters", new Value(parametersTable))
		parametersTable.add("TargetDirectory", new Value("C:/Target/"))
		parametersTable.add("PackageDirectory", new Value("C:/PackageRoot/"))
		parametersTable.add("Compiler", new Value("MOCK"))
		parametersTable.add("Flavor", new Value("debug"))

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
