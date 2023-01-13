// <copyright file="ResolveToolsTask.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

/// <summary>
/// The resolve dependencies build task that knows how to combine all previous state
/// into the active state.
/// </summary>
class ResolveDependenciesTask is SoupTask {
	/// <summary>
	/// Get the run before list
	/// </summary>
	static runBefore { [
		"BuildTask",
	]}

	/// <summary>
	/// Get the run after list
	/// </summary>
	static runAfter { [] }

	/// <summary>
	/// The Core Execute task
	/// </summary>
	evaluate() {
		var activeState = Soup.activeState
		var globalState = Soup.globalState

		var recipeTable = globalState["Recipe"].AsTable()
		var parametersTable = globalState["Parameters"].AsTable()
		var buildTable = activeState.EnsureValueTable(this.factory, "Build")

		if (activeState.TryGetValue("Dependencies", out var dependenciesValue))
		{
			var dependenciesTable = dependenciesValue.AsTable()
			if (dependenciesTable.TryGetValue("Runtime", out var runtimeValue))
			{
				var runtimeDependenciesTable = runtimeValue.AsTable()

				foreach (var dependencyName in runtimeDependenciesTable.Keys)
				{
					// Combine the core dependency build inputs for the core build task
					Soup.info("Combine Runtime Dependency: %(dependencyName)")
					var dependencyTable = runtimeDependenciesTable[dependencyName].AsTable()

					if (dependencyTable.TryGetValue("Build", out var buildValue)) {
						var dependencyBuildTable = buildValue.AsTable()
						var dependencyReference = GetRuntimeDependencyParameterReference(parametersTable, dependencyName)
						var dependencyRecipeReference = GetRuntimeDependencyReference(recipeTable, dependencyReference)

						if (!dependencyRecipeReference.ExcludeRuntime) {
							if (dependencyBuildTable.TryGetValue("RuntimeDependencies", out var runtimeDependenciesValue)) {
								var runtimeDependencies = runtimeDependenciesValue.AsList()
								buildTable.EnsureValueList(this.factory, "RuntimeDependencies").Append(runtimeDependencies)
							}
						} else {
							Soup.info("Excluding Runtime dependency content: %(dependencyName)")
						}

						if (dependencyBuildTable.TryGetValue("LinkDependencies", out var linkDependenciesValue)) {
							var linkDependencies = linkDependenciesValue.AsList()
							buildTable.EnsureValueList(this.factory, "LinkDependencies").Append(linkDependencies)
						}
					}
				}
			}
		}
	}

	(PackageReference Reference, bool ExcludeRuntime) GetRuntimeDependencyReference(IValueTable recipeTable, PackageReference dependencyReference)
	{
		if (recipeTable.TryGetValue("Dependencies", out var dependenciesValue))
		{
			var dependenciesTable = dependenciesValue.AsTable()
			if (dependenciesTable.TryGetValue("Runtime", out var runtimeValue))
			{
				var runtimeDependenciesList = runtimeValue.AsList()
				foreach (var dependencyValue in runtimeDependenciesList)
				{
					var dependency = ParseRecipeDependency(dependencyValue)
					if (dependency.Reference == dependencyReference)
						return dependency
				}

				Fiber.abort("Could not find a Runtime Dependency.")
			}
			else
			{
				Fiber.abort("Missing Dependencies value in Recipe Table.")
			}
		}
		else
		{
			Fiber.abort("Missing Dependencies value in Recipe Table.")
		}

	}

	(PackageReference Reference, bool ExcludeRuntime) ParseRecipeDependency(IValue dependency)
	{
		// A dependency can either be a string or a table with reference key
		if (dependency.IsString())
		{
			return (PackageReference.Parse(dependency.AsString()), false)
		}
		else if (dependency.IsTable())
		{
			var valueTable = dependency.AsTable()

			// Check for optional fields
			bool excludeRuntime = false
			if (valueTable.TryGetValue("ExcludeRuntime", out var excludeRuntimeValue))
			{
				excludeRuntime = excludeRuntimeValue.AsBoolean()
			}

			// Get the require fields
			if (valueTable.TryGetValue("Reference", out var referenceValue))
			{
				if (referenceValue.IsString())
				{
					return (PackageReference.Parse(referenceValue.AsString()), excludeRuntime)
				}
				else
				{
					Fiber.abort("Recipe dependency Reference must be type String.")
				}
			}
			else
			{
				Fiber.abort("Recipe dependency table missing required Reference value.")
			}
		}
		else
		{
			Fiber.abort("Unknown Recipe dependency type.")
		}
	}


	/// <summary>
	/// Find the original reference for the given dependency package name
	/// </summary>
	PackageReference GetRuntimeDependencyParameterReference(IValueTable parametersTable, string name)
	{
		if (parametersTable.TryGetValue("Dependencies", out var dependenciesValue))
		{
			var dependenciesTable = dependenciesValue.AsTable()
			if (dependenciesTable.TryGetValue("Runtime", out var runtimeValue))
			{
				var runtimeDependenciesTable = runtimeValue.AsTable()
				foreach (var dependencyValue in runtimeDependenciesTable)
				{
					if (dependencyValue.Key == name)
						return ParseParametersDependency(dependencyValue.Value)
				}

				Fiber.abort("Could not find a Runtime Dependency.")
			}
			else
			{
				Fiber.abort("Missing Dependencies value in Recipe Table.")
			}
		}
		else
		{
			Fiber.abort("Missing Dependencies value in Recipe Table.")
		}

	}

	PackageReference ParseParametersDependency(IValue dependency)
	{
		if (dependency.IsTable())
		{
			var valueTable = dependency.AsTable()

			// Get the require fields
			if (valueTable.TryGetValue("Reference", out var referenceValue))
			{
				if (referenceValue.IsString())
				{
					return PackageReference.Parse(referenceValue.AsString())
				}
				else
				{
					Fiber.abort("Recipe dependency Reference must be type String.")
				}
			}
			else
			{
				Fiber.abort("Parameter dependency table missing required Reference value.")
			}
		}
		else
		{
			Fiber.abort("Unknown Parameters dependency type.")
		}
	}
}
