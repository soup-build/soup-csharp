Name: 'csharp-compiler-roslyn'
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
		'soup|build-utils@0'
		'soup|csharp-compiler@0'
	]
}