// <copyright file="CommandLineBuilder.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

/// <summary>
/// A helper class that builds up command line arguments
/// </summary>
class CommandLineBuilder {
	construct new() {
		_commandArguments = []
	}

	/// <summary>
	/// Gets or sets the target name
	/// </summary>
	CommandArguments { _commandArguments }

	toString() {
		return _commandArguments.join(" ")
	}

	AddValueWithQuotes(value) {
		_arguments.add("\"%(value)\"")
	}

	AddFlag(flag) {
		_arguments.add("/%(flag)")
	}

	AddParameter(name, value) {
		_arguments.add("/%(name):%(value)")
	}

	AddParameterWithQuotes(name, value) {
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
			this.AddParameter(name, switchValue)
		}
	}
}
