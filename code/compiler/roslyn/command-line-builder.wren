// <copyright file="command-line-builder.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

/// <summary>
/// A helper class that builds up command line arguments
/// </summary>
class CommandLineBuilder {
	construct new() {
		_arguments = []
	}

	/// <summary>
	/// Gets or sets the target name
	/// </summary>
	CommandArguments { _arguments }

	toString {
		return _arguments.join(" ")
	}

	Append(value) {
		_arguments.add(value)
	}

	AppendValueWithQuotes(value) {
		_arguments.add("\"%(value)\"")
	}

	AppendFlag(flag) {
		_arguments.add("/%(flag)")
	}

	AppendSwitch(name, value) {
		_arguments.add("/%(name):%(value)")
	}

	AppendSwitchWithQuotes(name, value) {
		_arguments.add("/%(name):\"%(value)\"")
	}
	
	AppendSwitchUnquoted(name, value) {
		_arguments.add("/%(name)%(value)")
	}
	
	/// <summary>
	/// Set a boolean switch only if its value exists.
	/// </summary>
	AppendPlusOrMinusSwitch(name, value) {
		this.AppendSwitchUnquoted(name, value ? "+" : "-")
	}

	AppendParameterArrayIfNotEmpty(name, values, separator) {
		if (values.count > 0) {
			var switchValue = values.join(separator)
			this.AppendSwitch(name, switchValue)
		}
	}

	AppendIfTrue(name, value) {
		if (value) {
			this.AppendFlag(name)
		}
	}

	AppendPlusOrMinusSwitchIfNotNull(name, value) {
		if (!(value is Null)) {
			this.AppendPlusOrMinusSwitch(name, value)
		}
	}

	AppendSwitchIfNotNull(name, value) {
		if (!(value is Null)) {
			this.AppendSwitch(name, value)
		}
	}

	AppendSwitchWithQuotesIfNotNull(name, value) {
		if (!(value is Null)) {
			this.AppendSwitchWithQuotes(name, value)
		}
	}

	AppendArrayQuoted(values) {
		for (value in values) {
			this.AppendValueWithQuotes(value)
		}
	}
}
