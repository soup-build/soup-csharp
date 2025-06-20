import "./nuget-extension-unit-tests/Tasks/RecipeNugetPackagesTaskUnitTests" for RecipeNugetPackagesTaskUnitTests

var uut

// NugetExtension.UnitTests
uut = RecipeNugetPackagesTaskUnitTests.new()
uut.RunTests()