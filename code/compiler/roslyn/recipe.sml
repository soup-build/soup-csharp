Name: 'CSharp.Compiler.Roslyn'
Language: 'Wren|0'
Version: 0.14.0
Source: [
	'command-line-builder.wren'
	'managed-argument-builder.wren'
	'roslyn-argument-builder.wren'
	'roslyn-compiler.wren'
]
Dependencies: {
	Runtime: [
		'Soup|Build.Utils@0'
		'Soup|CSharp.Compiler@0'
	]
}