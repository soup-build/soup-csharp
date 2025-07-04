import "./nuget-extension-unit-tests/tasks/recipe-nuget-packages-task-unit-tests" for RecipeNugetPackagesTaskUnitTests

var uut

// NugetExtension.UnitTests
uut = RecipeNugetPackagesTaskUnitTests.new()
uut.RunTests()