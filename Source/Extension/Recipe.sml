Name: "Soup.CSharp"
Language: "Wren|0.1"
Version: "0.8.0"

Source: [
	"Tasks/BuildTask.wren"
	"Tasks/RecipeBuildTask.wren"
	"Tasks/ResolveDependenciesTask.wren"
	"Tasks/ResolveToolsTask.wren"
]

Dependencies: {
	Runtime: [
		"Soup.Build.Utils@0.2.0"
		"../Compiler/Core/"
		"../Compiler/Roslyn/"
	]
}