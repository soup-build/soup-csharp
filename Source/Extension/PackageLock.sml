Version: 5
Closures: {
	Root: {
		Wren: {
			"mwasplund|Soup.Build.Utils": { Version: "0.6.0", Build: "Build0", Tool: "Tool0" }
			"mwasplund|Soup.CSharp.Compiler": { Version: "../Compiler/Core/", Build: "Build0", Tool: "Tool0" }
			"mwasplund|Soup.CSharp.Compiler.Roslyn": { Version: "../Compiler/Roslyn/", Build: "Build0", Tool: "Tool0" }
			"mwasplund|Soup.CSharp": { Version: "../Extension", Build: "Build0", Tool: "Tool0" }
			"Soup.CSharp": { Version: "../Extension", Build: "Build0", Tool: "Tool0" }
		}
	}
	Build0: {
		Wren: {
			"mwasplund|Soup.Wren": { Version: "0.2.0" }
		}
	}
	Tool0: {
		"C++": {
			"mwasplund|copy": { Version: "1.0.0" }
			"mwasplund|mkdir": { Version: "1.0.0" }
		}
	}
}