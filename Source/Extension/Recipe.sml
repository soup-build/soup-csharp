Name: "Soup.CSharp"
Language: "Wren|0.1"
Version: "0.11.0"
Source: [
	"Tasks/BuildTask.wren"
	"Tasks/InitializeDefaultsTask.wren"
	"Tasks/RecipeBuildTask.wren"
	"Tasks/ResolveDependenciesTask.wren"
	"Tasks/ResolveToolsTask.wren"
]

Dependencies: {
	Runtime: [
		"Soup.Build.Utils@0.3"
		"Soup.CSharp.Compiler@0.8.0"
		"Soup.CSharp.Compiler.Roslyn@0.8.0"
	]
	Tool: [
		"C++|copy@1.0"
		"C++|mkdir@1.0"
	]
}