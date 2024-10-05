Name: 'Soup.CSharp'
Language: 'Wren|0'
Version: '0.15.0'
Source: [
	'Tasks/BuildTask.wren'
	'Tasks/ExpandSourceTask.wren'
	'Tasks/InitializeDefaultsTask.wren'
	'Tasks/RecipeBuildTask.wren'
	'Tasks/ResolveDependenciesTask.wren'
	'Tasks/ResolveToolsTask.wren'
]
Dependencies: {
	Runtime: [
		'mwasplund|Soup.Build.Utils@0'
		'mwasplund|Soup.CSharp.Compiler@0'
		'mwasplund|Soup.CSharp.Compiler.Roslyn@0'
	]
	Tool: [
		'[C++]mwasplund|copy@1'
		'[C++]mwasplund|mkdir@1'
	]
}