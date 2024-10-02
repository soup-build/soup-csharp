// <copyright file="ManagedCompileOptions.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

import "mwasplund|Soup.Build.Utils:./ListExtensions" for ListExtensions

/// <summary>
/// The enumeration of link targets
/// </summary>
class LinkTarget {
	/// <summary>
	/// Dynamic Library
	/// </summary>
	static Library { "library" }

	/// <summary>
	/// Executable
	/// </summary>
	static Executable { "exe" }
}

/// <summary>
/// The set of compiler options
/// </summary>
class ManagedCompileOptions {
	construct new() {
		_noConfig = true
		_addModules = []
		_codePage = null
		_emitDebugInformation = true
		_debugType = "portable"
		_delaySign = null
		_reportIVTs = false
		_fileAlignment = 512
		_optimize = false
		_outputAssembly = null
		_outputRefAssembly = null
		_targetType = null
		_treatWarningsAsErrors = false
		_utf8Output = true
		_deterministic = true
		_langVersion = "9.0"
		_analyzers = []
		_sources = []
	}

	/// <summary>
	/// Gets or sets a value indicating whether to disable config
	/// </summary>
	NoConfig { _noConfig }
	NoConfig=(value) { _noConfig = value }

	/// <summary>
	/// Gets or sets the add modules
	/// </summary>
	AddModules { _addModules }
	AddModules=(value) { _addModules = value }

	/// <summary>
	/// Gets or sets the code page
	/// </summary>
	CodePage { _codePage }
	CodePage=(value) { __codePage = value }

	/// <summary>
	/// Gets or sets a value indicating whether to emit debug information
	/// </summary>
	EmitDebugInformation { _emitDebugInformation }
	EmitDebugInformation=(value) { _emitDebugInformation = value }

	/// <summary>
	/// Gets or sets the debug type
	/// </summary>
	DebugType { _debugType }
	DebugType=(value) { _debugType = value }

	/// <summary>
	/// Gets or sets a value indicating whether to delay sign
	/// </summary>
	DelaySign { _delaySign }
	DelaySign=(value) { _delaySign = value }

	/// <summary>
	/// Gets or sets a value indicating whether to report IVTs
	/// </summary>
	ReportIVTs { _reportIVTs }
	ReportIVTs=(value) { _reportIVTs = value }

	/// <summary>
	/// Gets or sets the file alignment
	/// </summary>
	FileAlignment { _fileAlignment }
	FileAlignment=(value) { _fileAlignment = value }

	/// <summary>
	/// Gets or sets a value indicating whether to optimize
	/// </summary>
	Optimize { _optimize }
	Optimize=(value) { _optimize = value }

	/// <summary>
	/// Gets or sets the output assembly
	/// </summary>
	OutputAssembly { _outputAssembly }
	OutputAssembly=(value) { _outputAssembly = value }

	/// <summary>
	/// Gets or sets the output reference assembly
	/// </summary>
	OutputRefAssembly { _outputRefAssembly }
	OutputRefAssembly=(value) { _outputRefAssembly = value }

	/// <summary>
	/// Gets or sets the target type
	/// </summary>
	TargetType { _targetType }
	TargetType=(value) { _targetType = value }

	/// <summary>
	/// Gets or sets a value indicating whether to treat warnings as errors
	/// </summary>
	TreatWarningsAsErrors { _treatWarningsAsErrors }
	TreatWarningsAsErrors=(value) { _treatWarningsAsErrors = value }

	/// <summary>
	/// Gets or sets a value indicating whether to output as utf8
	/// </summary>
	Utf8Output { _utf8Output }
	Utf8Output=(value) { _utf8Output = value }

	/// <summary>
	/// Gets or sets a value indicating whether deterministic
	/// </summary>
	Deterministic { _deterministic }
	Deterministic=(value) { _deterministic = value }

	/// <summary>
	/// Gets or sets the language version
	/// </summary>
	LangVersion { _langVersion }
	LangVersion=(value) { _langVersion = value }

	/// <summary>
	/// Gets or sets the list of analyzers
	/// </summary>
	Analyzers { _analyzers }
	Analyzers=(value) { _analyzers = value }

	/// <summary>
	/// Gets or sets the list of source files
	/// </summary>
	Sources { _sources }
	Sources=(value) { _sources = value }

	Equals(rhs) {
		if (rhs is Null) {
			return false
		}

		// Return true if the fields match.
		return this.NoConfig == rhs.NoConfig &&
			ListExtensions.SequenceEqual(this.AddModules, rhs.AddModules) &&
			this.CodePage == rhs.CodePage &&
			this.EmitDebugInformation == rhs.EmitDebugInformation &&
			this.DebugType == rhs.DebugType &&
			this.DelaySign == rhs.DelaySign &&
			this.ReportIVTs == rhs.ReportIVTs &&
			this.FileAlignment == rhs.FileAlignment &&
			this.Optimize == rhs.Optimize &&
			this.OutputAssembly == rhs.OutputAssembly &&
			this.OutputRefAssembly == rhs.OutputRefAssembly &&
			this.TargetType == rhs.TargetType &&
			this.TreatWarningsAsErrors == rhs.TreatWarningsAsErrors &&
			this.Utf8Output == rhs.Utf8Output &&
			this.Deterministic == rhs.Deterministic &&
			this.LangVersion == rhs.LangVersion &&
			ListExtensions.SequenceEqual(this.Analyzers, rhs.Analyzers) &&
			ListExtensions.SequenceEqual(this.Sources, rhs.Sources)
	}

	toString {
		return "NoConfig=\"%(_noConfig)\", AddModules=%(_addModules) CodePage=%(_codePage), EmitDebugInformation=%(_emitDebugInformation), DebugType=%(_debugType), DelaySign=%(_delaySign), ReportIVTs=%(_reportIVTs) FileAlignment=\"%(_fileAlignment)\", Optimize=\"%(_optimize)\", OutputAssembly=%(_outputAssembly), OutputRefAssembly=%(_outputRefAssembly), TargetType=%(_targetType), TreatWarningsAsErrors=%(_treatWarningsAsErrors), Utf8Output=%(_utf8Output), Deterministic=\"%(_deterministic)\", LangVersion=%(_langVersion), Analyzers=%(_analyzers), Sources=%(_sources)"
	}
}
