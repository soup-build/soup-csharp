import "./Compiler/Core.UnitTests/BuildEngineUnitTests" for BuildEngineUnitTests
import "./Compiler/Roslyn.UnitTests/RoslynArgumentBuilderUnitTests" for RoslynArgumentBuilderUnitTests
import "./Compiler/Roslyn.UnitTests/RoslynCompilerUnitTests" for RoslynCompilerUnitTests
import "./Extension.UnitTests/Tasks/BuildTaskUnitTests" for BuildTaskUnitTests
import "./Extension.UnitTests/Tasks/RecipeBuildTaskUnitTests" for RecipeBuildTaskUnitTests
import "./Extension.UnitTests/Tasks/ResolveToolsTaskUnitTests" for ResolveToolsTaskUnitTests

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