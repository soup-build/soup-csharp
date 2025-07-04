import "./compiler/core-unit-tests/BuildEngineUnitTests" for BuildEngineUnitTests
import "./compiler/roslyn-unit-tests/RoslynArgumentBuilderUnitTests" for RoslynArgumentBuilderUnitTests
import "./compiler/roslyn-unit-tests/RoslynCompilerUnitTests" for RoslynCompilerUnitTests
import "./extension-unit-tests/Tasks/BuildTaskUnitTests" for BuildTaskUnitTests
import "./extension-unit-tests/Tasks/RecipeBuildTaskUnitTests" for RecipeBuildTaskUnitTests
import "./extension-unit-tests/Tasks/ResolveToolsTaskUnitTests" for ResolveToolsTaskUnitTests

var uut

// Compiler.Core.UnitTests
uut = BuildEngineUnitTests.new()
uut.RunTests()

// Compiler.Roslyn.UnitTests
uut = RoslynArgumentBuilderUnitTests.new()
uut.RunTests()
uut = RoslynCompilerUnitTests.new()
uut.RunTests()

// Extension.UnitTests
uut = BuildTaskUnitTests.new()
uut.RunTests()
uut = RecipeBuildTaskUnitTests.new()
uut.RunTests()
uut = ResolveToolsTaskUnitTests.new()
uut.RunTests()