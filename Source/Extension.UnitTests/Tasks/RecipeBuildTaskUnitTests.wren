// <copyright file="RecipeBuildTaskUnitTests.cs" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

using Opal
using Soup.Build.Runtime
using Soup.Build.Utilities
using System.Collections.Generic
using Xunit

namespace Soup.Build.CSharp.UnitTests
{
    public class RecipeBuildTaskUnitTests
    {
        // [Fact]
        public Initialize_Success()
        {
            var buildState = new MockBuildState()
            var factory = new ValueFactory()
            var uut = new RecipeBuildTask(buildState, factory)
        }

        // [Fact]
        public Build_Executable()
        {
            // Register the test systems
            var testListener = new TestTraceListener()
            using (var scopedTraceListener = new ScopedTraceListenerRegister(testListener))
            {
                // Setup the input build state
                var buildState = new MockBuildState()
                var state = buildState.ActiveState
                state.add("PlatformLibraries", new Value(new ValueList()))
                state.add("PlatformIncludePaths", new Value(new ValueList()))
                state.add("PlatformLibraryPaths", new Value(new ValueList()))
                state.add("PlatformPreprocessorDefinitions", new Value(new ValueList()))

                // Setup recipe table
                var buildTable = new ValueTable()
                state.add("Recipe", new Value(buildTable))
                buildTable.add("Name", new Value("Program"))

                // Setup parameters table
                var parametersTable = new ValueTable()
                state.add("Parameters", new Value(parametersTable))
                parametersTable.add("TargetDirectory", new Value("C:/Target/"))
                parametersTable.add("PackageDirectory", new Value("C:/PackageRoot/"))
                parametersTable.add("Compiler", new Value("MOCK"))
                parametersTable.add("Flavor", new Value("debug"))

                var factory = new ValueFactory()
                var uut = new RecipeBuildTask(buildState, factory)

                uut.Execute()
 
                // Verify expected logs
                Assert.Equal(
                    [
                    {
                    },
				    testListener.GetMessages())

                // Verify build state
                var expectedBuildOperations = [

                Assert.Equal(
                    expectedBuildOperations,
                    buildState.GetBuildOperations())

                // TODO: Verify output build state
            }
        }
    }
}
