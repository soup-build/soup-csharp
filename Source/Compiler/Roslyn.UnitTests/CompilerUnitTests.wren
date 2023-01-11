// <copyright file="CompilerUnitTests.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

class CompilerTests {
	// [Fact]
	void Initialize() {
		var uut = new Compiler(
			new Path("C:/bin/mock.csc.exe"))
		Assert.Equal("Roslyn", uut.Name)
		Assert.Equal("obj", uut.ObjectFileExtension)
		Assert.Equal("lib", uut.StaticLibraryFileExtension)
		Assert.Equal("dll", uut.DynamicLibraryFileExtension)
	}

	// [Fact]
	void Compile_Simple()
	{
		var uut = new Compiler(
			new Path("C:/bin/mock.csc.exe"))

		var arguments = new CompileArguments()
		{
			Target = new Path("bin/Target.dll"),
			ReferenceTarget = new Path("ref/Target.dll"),
			SourceRootDirectory = new Path("C:/source/"),
			TargetRootDirectory = new Path("C:/target/"),
			ObjectDirectory = new Path("ObjectDir/"),
			SourceFiles = new List<Path>()
			{
				new Path("File.cs"),
			},
		}

		var result = uut.CreateCompileOperations(arguments)

		// Verify result
		var expected = new List<BuildOperation>()
		{
			new BuildOperation(
				"WriteFile [./ObjectDir/CompileArguments.rsp]",
				new Path("C:/target/"),
				new Path("./writefile.exe"),
				"\"./ObjectDir/CompileArguments.rsp\" \"/unsafe- /checked- /fullpaths /nostdlib+ /errorreport:prompt /warn:5 /errorendlocation /preferreduilang:en-US /highentropyva+ /nullable:enable /debug+ /debug:portable /filealign:512 /optimize- /out:\"C:/target/bin/Target.dll\" /refout:\"C:/target/ref/Target.dll\" /target:library /warnaserror- /utf8output /deterministic+ /langversion:9.0 \"./File.cs\"\"",
				new List<Path>(),
				new List<Path>()
				{
					new Path("./ObjectDir/CompileArguments.rsp"),
				}),
			new BuildOperation(
				"Compile - ./bin/Target.dll",
				new Path("C:/source/"),
				new Path("C:/bin/mock.csc.exe"),
				"@C:/target/ObjectDir/CompileArguments.rsp /noconfig",
				new List<Path>()
				{
					new Path("C:/target/ObjectDir/CompileArguments.rsp"),
					new Path("./File.cs"),
				},
				new List<Path>()
				{
					new Path("C:/target/bin/Target.dll"),
					new Path("C:/target/bin/Target.pdb"),
					new Path("C:/target/ref/Target.dll"),
				}),
			}

		Assert.Equal(expected, result)
	}
}
