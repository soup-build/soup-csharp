Version: 4
Closures: {
	Root: {
		"C++": [
			{ Name: "copy", Version: "1.0.0", Build: "Build0" }
			{ Name: "mkdir", Version: "1.0.0", Build: "Build0" }
		]
		Wren: [
			{ Name: "Soup.Build.Utils", Version: "0.3.0", Build: "Build0" }
			{ Name: "Soup.CSharp", Version: "../Extension", Build: "Build0" }
			{ Name: "Soup.CSharp.Compiler", Version: "0.8.0", Build: "Build0" }
			{ Name: "Soup.CSharp.Compiler.Roslyn", Version: "0.8.0", Build: "Build0" }
		]
	}
	Build0: {
		Wren: [
			{ Name: "Soup.Cpp", Version: "0.6.2" }
			{ Name: "Soup.Wren", Version: "0.1.2" }
		]
		"C++": [
			{ Name: "copy", Version: "1.0.0", Build: "Build0" }
			{ Name: "mkdir", Version: "1.0.0", Build: "Build0" }
		]
	}
}