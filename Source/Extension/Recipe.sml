Name: "Soup.CSharp"
Language: "C#|0.1"
Version: "0.7.1"

Source: [
	"Tasks/BuildTask.cs"
	"Tasks/RecipeBuildTask.cs"
	"Tasks/ResolveDependenciesTask.cs"
	"Tasks/ResolveToolsTask.cs"
]

Dependencies: {
	Runtime: [
		{ Reference: "Opal@1.1.0" }
		{ Reference: "Soup.Build@0.2.0", ExcludeRuntime: true }
		{ Reference: "Soup.Build.Extensions@0.4.0" }
		{ Reference: "Soup.Build.Extensions.Utilities@0.4.0" }
		{ Reference: "Soup.CSharp.Compiler@0.6.0" }
		{ Reference: "Soup.CSharp.Compiler.Roslyn@0.6.0" }
	]
}