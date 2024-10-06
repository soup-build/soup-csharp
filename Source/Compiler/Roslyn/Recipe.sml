Name: 'CSharp.Compiler.Roslyn'
Language: 'Wren|0'
Version: '0.13.0'
Source: [
	'CommandLineBuilder.wren'
	'ManagedArgumentBuilder.wren'
	'RoslynArgumentBuilder.wren'
	'RoslynCompiler.wren'
]

Dependencies: {
	Runtime: [
		'Soup|Build.Utils@0'
		'Soup|CSharp.Compiler@0'
	]
}