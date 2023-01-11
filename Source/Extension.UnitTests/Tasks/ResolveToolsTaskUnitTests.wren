// <copyright file="ResolveToolsTaskUnitTests.cs" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

using Opal
using Soup.Build.Runtime
using Soup.Build.Utilities
using System.Collections.Generic
using Xunit

namespace Soup.Build.CSharp.UnitTests
{
	public class ResolveToolsTaskUnitTests
	{
		// [Fact]
		public Initialize_Success()
		{
			var buildState = new MockBuildState()
			var factory = new ValueFactory()
			var uut = new ResolveToolsTask(buildState, factory)
		}

		// [Fact]
		public Execute()
		{
			// Register the test systems
			var testListener = new TestTraceListener()
			using (var scopedTraceListener = new ScopedTraceListenerRegister(testListener))
			{
				// Setup the input build state
				var buildState = new MockBuildState()
				var state = buildState.ActiveState

				// Set the sdks
				var sdks = new ValueList()
				sdks.add(new Value(new ValueTable()
				{
					{ "Name", new Value("Roslyn") },
					{
						"Properties",
						new Value(new ValueTable()
						{
							{ "ToolsRoot", new Value("C:/Roslyn/ToolsRoot/") }
						})
					},
				}))

				// Setup parameters table
				var parametersTable = new ValueTable()
				state.add("Parameters", new Value(parametersTable))
				parametersTable.add("SDKs", new Value(sdks))
				parametersTable.add("System", new Value("win32"))
				parametersTable.add("Architecture", new Value("x64"))

				// Setup build table
				var buildTable = new ValueTable()
				state.add("Build", new Value(buildTable))

				var factory = new ValueFactory()
				var uut = new ResolveToolsTask(buildState, factory)

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
			}
		}
	}
}
