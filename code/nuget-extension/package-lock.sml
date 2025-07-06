Version: 5
Closures: {
	Root: {
		Wren: {
			'CSharp.Nuget': { Version: './', Build: 'Build0', Tool: 'Tool0' }
			'Soup|Build.Utils': { Version: 0.9.0, Build: 'Build0', Tool: 'Tool0' }
			'Soup|CSharp.Nuget': { Version: './', Build: 'Build0', Tool: 'Tool0' }
		}
	}
	Build0: {
		Wren: {
			'Soup|Wren': { Version: 0.5.1 }
		}
	}
	Tool0: {
		'C++': {
			'mwasplund|copy': { Version: 1.2.0 }
			'mwasplund|mkdir': { Version: 1.2.0 }
		}
	}
}