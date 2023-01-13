// <copyright file="SemanticVersion.wren" company="Soup">
// Copyright (c) Soup. All rights reserved.
// </copyright>

/// <summary>
/// The semantic version class.
/// </summary>
class SemanticVersion {
	/// <summary>
	/// Initializes a new instance of the <see cref="SemanticVersion"/> class.
	/// </summary>
	construct new() {
		_major = 0
		_minor = null
		_patch = null
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="SemanticVersion"/> class.
	/// </summary>
	/// <param name="major">The major version.</param>
	construct new(major) {
		_major = major
		_minor = null
		_patch = null
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="SemanticVersion"/> class.
	/// </summary>
	/// <param name="major">The major version.</param>
	/// <param name="minor">The minor version.</param>
	/// <param name="patch">The patch version.</param>
	construct new(major, minor, patch) {
		_major = major
		_minor = minor
		_patch = patch
	}

	/// <summary>
	/// Gets or sets the version major.
	/// </summary>
	Major { _major }

	/// <summary>
	/// Gets or sets the version minor.
	/// </summary>
	Minor { _minor }

	/// <summary>
	/// Gets or sets the version patch.
	/// </summary>
	Patch { _patch }

	/// <summary>
	/// Parse the value.
	/// </summary>
	/// <param name="value">The value.</param>
	static Parse(value) {
		// Parse the integer values
		// TODO: Perform my own search to save string creation
		var stringValues = value.split(".")
		if (stringValues.count < 1 || stringValues.count > 3) {
			Fiber.abort("The version string must have one to three values.")
		}

		var intValues = []
		for (stringValue in stringValues) {
			var intValue = Num.fromString(stringValue)
			if (!(intValue is Null)) {
				intValues.add(intValue)
			} else {
				Fiber.abort("Invalid version string: \"%(value)\"")
			}
		}

		var major = intValues[0]

		var minor = null
		if (intValues.count >= 2) {
			minor = intValues[1]
		}

		var patch = null
		if (intValues.count >= 3) {
			patch = intValues[2]
		}

		return SemanticVersion.new(
			major,
			minor,
			patch)
	}

	static IsUpCompatible(requested, target) {
		// The target version must be fully qualified
		if (!target.Minor.HasValue) {
			Fiber.abort("Target must have minor version")
		}
		if (!target.Patch.HasValue) {
			Fiber.abort("Target must have patch version")
		}

		if (requested.Major == target.Major) {
			if (!requested.Minor.HasValue || target.Minor > requested.Minor) {
				// If the Minor version is acceptable increase then allow it
				return true
			} else if (requested.Minor == target.Minor) {
				// Check that the patch is not backtracking
				return !requested.Patch.HasValue || target.Patch >= requested.Patch
			} else {
				// Minor version drops not allowed
				return false
			}
		} else {
			// The Major version must match
			return false
		}
	}

	==(rhs) {
		if (rhs is Null) {
			return false
		}

		return _major == rhs.Major &&
			_minor == rhs.Minor &&
			_patch == rhs.Patch
	}

	!=(rhs) {
		return !(lhs == rhs)
	}

	/// <summary>
	/// Comparison operator.
	/// </summary>
	/// <param name="lhs">The left hand side.</param>
	/// <param name="rhs">The right hand side.</param>
	<(rhs) {
		return _major < rhs.Major ||
			_minor < rhs.Minor ||
			_patch < rhs.Patch
	}

	>(rhs) {
		return _major > rhs.Major ||
			_minor > rhs.Minor ||
			_patch > rhs.Patch
	}

	/// <summary>
	/// Convert to string.
	/// </summary>
	toString {
		if (_minor is Null) {
			return "%(_major)"
		} else if (_patch is Null) {
			return "%(_major).%(_minor)"
		} else {
			return "%(_major).%(_minor).%(_patch)"
		}
	}
}
