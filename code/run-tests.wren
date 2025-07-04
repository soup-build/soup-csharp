import "./compiler/core-unit-tests/build-engine-unit-tests" for BuildEngineUnitTests
import "./compiler/roslyn-unit-tests/roslyn-argument-builder-unit-tests" for RoslynArgumentBuilderUnitTests
import "./compiler/roslyn-unit-tests/roslyn-compiler-unit-tests" for RoslynCompilerUnitTests
import "./extension-unit-tests/tasks/build-task-unit-tests" for BuildTaskUnitTests
import "./extension-unit-tests/tasks/recipe-build-task-unit-tests" for RecipeBuildTaskUnitTests
import "./extension-unit-tests/tasks/resolve-tools-task-unit-tests" for ResolveToolsTaskUnitTests

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