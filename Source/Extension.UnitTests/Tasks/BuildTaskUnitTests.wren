// <copyright file="BuildTaskUnitTests.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

class BuildTaskUnitTests {
	// [Fact]
	public Initialize_Success()
	{
		var buildState = new MockBuildState()
		var factory = new ValueFactory()
		var uut = new BuildTask(buildState, factory)
	}

	// [Fact]
	public Build_Executable()
	{
		// Setup the input build state
		var buildState = new MockBuildState()
		var state = buildState.ActiveState

		// Setup build table
		var buildTable = new ValueTable()
		state.add("Build", new Value(buildTable))
		buildTable.add("TargetName", new Value("Program"))
		buildTable.add("TargetType", new Value((long)BuildTargetType.Executable))
		buildTable.add("SourceRootDirectory", new Value("C:/source/"))
		buildTable.add("TargetRootDirectory", new Value("C:/target/"))
		buildTable.add("ObjectDirectory", new Value("obj/"))
		buildTable.add("BinaryDirectory", new Value("bin/"))
		buildTable.add(
			"Source",
			new Value(new ValueList()
				{
					new Value("TestFile.cs"),
				}))

		// Setup parameters table
		var parametersTable = new ValueTable()
		state.add("Parameters", new Value(parametersTable))
		parametersTable.add("Architecture", new Value("x64"))
		parametersTable.add("Compiler", new Value("MOCK"))

		// Register the mock compiler
		var compiler = new Compiler.Mock.Compiler()
		var compilerFactory = new Dictionary<string, Func<IValueTable, ICompiler>>()
		compilerFactory.add("MOCK", (IValueTable state) { { return compiler })

		var factory = new ValueFactory()
		var uut = new BuildTask(buildState, factory, compilerFactory)

		uut.Execute()

		// Verify expected logs
		// Assert.Equal(
		// 	[
		// 		"INFO: Build Generate Done"
		// 	],
		// 	testListener.GetMessages())

		var expectedCompileArguments = CompileArguments.new()
		{
			Target = Path.new("./bin/Program.mock.dll"),
			ReferenceTarget = Path.new("./bin/ref/Program.mock.dll"),
			TargetType = LinkTarget.Executable,
			SourceRootDirectory = Path.new("C:/source/"),
			TargetRootDirectory = Path.new("C:/target/"),
			ObjectDirectory = Path.new("obj/"),
			SourceFiles = [
				Path.new("TestFile.cs")
			],
		}

		// Verify expected compiler calls
		Assert.Equal(
			[
				expectedCompileArguments,
			],
			compiler.GetCompileRequests())

		// Verify build state
		var expectedBuildOperations = [
			BuildOperation.new(
				"MakeDir [./obj/]",
				Path.new("C:/target/"),
				Path.new("C:/mkdir.exe"),
				"\"./obj/\"",
				[],
				[
					Path.new("./obj/"),
				]),
			BuildOperation.new(
				"MakeDir [./bin/]",
				Path.new("C:/target/"),
				Path.new("C:/mkdir.exe"),
				"\"./bin/\"",
				[],
				[
					Path.new("./bin/"),
				]),
			BuildOperation.new(
				"MakeDir [./bin/ref/]",
				Path.new("C:/target/"),
				Path.new("C:/mkdir.exe"),
				"\"./bin/ref/\"",
				[],
				[
					Path.new("./bin/ref/"),
				]),
			BuildOperation.new(
				"MockCompile: 1",
				Path.new("MockWorkingDirectory"),
				Path.new("MockCompiler.exe"),
				"Arguments",
				[
					Path.new("./InputFile.in"),
				],
				[
					Path.new("./OutputFile.out"),
				]),
			BuildOperation.new(
				"WriteFile [./bin/Program.runtimeconfig.json]",
				Path.new("C:/target/"),
				Path.new("./writefile.exe"),
				"./bin/Program.runtimeconfig.json"" ""{
""runtimeOptions"": {
""tfm"": ""net6.0"",
""framework"": {
""name"": ""Microsoft.NETCore.App"",
""version"": ""6.0.0""
},
""configProperties"": {
""System.Reflection.Metadata.MetadataUpdater.IsSupported"": false
}
}
}""",
				[],
				[
					Path.new("./bin/Program.runtimeconfig.json"),
				]),
		]

		Assert.Equal(
			expectedBuildOperations,
			buildState.GetBuildOperations())
	}

	// [Fact]
	public Build_Library_MultipleFiles() {
		// Setup the input build state
		var buildState = new MockBuildState()
		var state = buildState.ActiveState

		// Setup build table
		var buildTable = new ValueTable()
		state.add("Build", new Value(buildTable))
		buildTable.add("TargetName", new Value("Library"))
		buildTable.add("TargetType", new Value((long)BuildTargetType.Library))
		buildTable.add("SourceRootDirectory", new Value("C:/source/"))
		buildTable.add("TargetRootDirectory", new Value("C:/target/"))
		buildTable.add("ObjectDirectory", new Value("obj/"))
		buildTable.add("BinaryDirectory", new Value("bin/"))
		buildTable.add("Source", new Value(new ValueList()
		{
			new Value("TestFile1.cpp"),
			new Value("TestFile2.cpp"),
			new Value("TestFile3.cpp"),
		}))
		buildTable.add("IncludeDirectories", new Value(new ValueList()
		{
			new Value("Folder"),
			new Value("AnotherFolder/Sub"),
		}))
		buildTable.add("ModuleDependencies", new Value(new ValueList()
		{
			new Value("../Other/bin/OtherModule1.mock.bmi"),
			new Value("../OtherModule2.mock.bmi"),
		}))
		buildTable.add("OptimizationLevel", new Value((long)BuildOptimizationLevel.None))

		// Setup parameters table
		var parametersTable = new ValueTable()
		state.add("Parameters", new Value(parametersTable))
		parametersTable.add("Architecture", new Value("x64"))
		parametersTable.add("Compiler", new Value("MOCK"))

		// Register the mock compiler
		var compiler = new Compiler.Mock.Compiler()
		var compilerFactory = new Dictionary<string, Func<IValueTable, ICompiler>>()
		compilerFactory.add("MOCK", (IValueTable state) { { return compiler })

		var factory = new ValueFactory()
		var uut = new BuildTask(buildState, factory, compilerFactory)

		uut.Execute()

		// Verify expected logs
		// Assert.Equal(
		// 	[
		// 		"INFO: Build Generate Done",
		// 	],
		// 	testListener.GetMessages())

		// Setup the shared arguments
		var expectedCompileArguments = CompileArguments.new()
		{
			Target = Path.new("./bin/Library.mock.dll"),
			ReferenceTarget = Path.new("./bin/ref/Library.mock.dll"),
			SourceRootDirectory = Path.new("C:/source/"),
			TargetRootDirectory = Path.new("C:/target/"),
			ObjectDirectory = Path.new("obj/"),
			SourceFiles = [
			{
				Path.new("TestFile1.cpp"),
				Path.new("TestFile2.cpp"),
				Path.new("TestFile3.cpp"),
			},
		}

		// Verify expected compiler calls
		Assert.Equal(
			new List<CompileArguments>()
			{
				expectedCompileArguments,
			},
			compiler.GetCompileRequests())

		// Verify build state
		var expectedBuildOperations = [
		{
			BuildOperation.new(
				"MakeDir [./obj/]",
				Path.new("C:/target/"),
				Path.new("C:/mkdir.exe"),
				"\"./obj/\"",
				[,
				[
				{
					Path.new("./obj/"),
				}),
			BuildOperation.new(
				"MakeDir [./bin/]",
				Path.new("C:/target/"),
				Path.new("C:/mkdir.exe"),
				"\"./bin/\"",
				[,
				[
				{
					Path.new("./bin/"),
				}),
			BuildOperation.new(
				"MakeDir [./bin/ref/]",
				Path.new("C:/target/"),
				Path.new("C:/mkdir.exe"),
				"\"./bin/ref/\"",
				[,
				[
				{
					Path.new("./bin/ref/"),
				}),
			BuildOperation.new(
				"MockCompile: 1",
				Path.new("MockWorkingDirectory"),
				Path.new("MockCompiler.exe"),
				"Arguments",
				[
					Path.new("./InputFile.in"),
				],
				[
					Path.new("./OutputFile.out"),
				]),
		}

		Assert.Equal(
			expectedBuildOperations,
			buildState.GetBuildOperations())
	}
}
