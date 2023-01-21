Version: 4
Closures: {
	Root: {
		Wren: [
			{ Name: "Soup.Build.Utils", Version: "0.2.0", Build: "Build0" }
			{ Name: "Soup.CSharp", Version: "../Extension", Build: "Build0" }
			{ Name: "Soup.CSharp.Compiler", Version: "../Compiler/Core/", Build: "Build0" }
			{ Name: "Soup.CSharp.Compiler.Roslyn", Version: "../Compiler/Roslyn/", Build: "Build0" }
		]
	}
	Build0: {
		Wren: [
			{ Name: "Soup.Wren", Version: "0.1.0" }
		]
	}
}