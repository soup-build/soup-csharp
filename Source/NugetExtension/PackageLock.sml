Version: 5
Closures: {
	Root: {
		Wren: {
			'Soup|Build.Utils': { Version: '0.7.0', Build: 'Build0', Tool: 'Tool0' }
			'Soup|CSharp.Nuget': { Version: '../NugetExtension', Build: 'Build0', Tool: 'Tool0' }
			'CSharp.Nuget': { Version: '../NugetExtension', Build: 'Build0', Tool: 'Tool0' }
		}
	}
	Build0: {
		Wren: {
			'Soup|Wren': { Version: '0.4.1' }
		}
	}
	Tool0: {
		'C++': {
			'mwasplund|copy': { Version: '1.0.0' }
			'mwasplund|mkdir': { Version: '1.0.0' }
		}
	}
}