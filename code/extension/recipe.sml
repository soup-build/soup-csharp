Name: 'csharp'
Language: 'Wren|0'
Version: 0.18.1
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
		'soup|build-utils@0'
		'soup|csharp-compiler@0'
		'soup|csharp-compiler-roslyn@0'
	]
	Tool: [
		'[C++]mwasplund|copy@1'
		'[C++]mwasplund|mkdir@1'
	]
}