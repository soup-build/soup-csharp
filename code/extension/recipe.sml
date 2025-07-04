Name: 'CSharp'
Language: 'Wren|0'
Version: 0.16.0
Source: [
	'tasks/build-task.wren'
	'tasks/expand-source-task.wren'
	'tasks/initialize-defaults-task.wren'
	'tasks/recipe-build-task.wren'
	'tasks/resolve-dependencies-task.wren'
	'tasks/resolve-tools-task.wren'
]
Dependencies: {
	Runtime: [
		'Soup|Build.Utils@0'
		'Soup|CSharp.Compiler@0'
		'Soup|CSharp.Compiler.Roslyn@0'
	]
	Tool: [
		'[C++]mwasplund|copy@1'
		'[C++]mwasplund|mkdir@1'
	]
}