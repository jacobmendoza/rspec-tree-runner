/** @babel */
import JsonSanitizer from './json-sanitizer';

// Trying to address the problem of non-json text being inserted
// into stdout when analysing the result of the RSpec test runner.
// This happens when some gems (or even the user) write output
// before, after or in the middle of the RSpec execution process,
// even if the formatter being used is JSON an that makes the string
// invalid.
//
// Despite it seems reasonable think that an implementation based
// on a queue could be more efficient, I'm choosing the easiest solution
// for now, trying to avoid some unexpected edge cases.
//
// As the JSON of the RSpec runner should be the first in the output,
// assume '{' as the first character of the JSON that we want to extract,
// find the last '}' and try to parse. If it fails, repeat the process
// with the previous brace till succeeds or fails.
//
// Future improvements: Extract several JSON valid objects if they exist
// and detect the one that belongs to RSpec runner output.
class JsonExtractor {
	constructor(sanitizer = new JsonSanitizer()) {
		this.sanitizer = sanitizer;
	}

	extract(data) {
		const sanitizedData = this.sanitizer.sanitize(data);

		const firstBrace = sanitizedData.indexOf('{');
		let lastBrace = sanitizedData.lastIndexOf('}');

		if (firstBrace === -1 || lastBrace === -1) {
			return {};
		}

		let result;
		let found = false;
		let candidate = sanitizedData.substring(firstBrace, lastBrace + 1);

		while (!found && lastBrace !== -1) {
			result = this.testCandidate(candidate);
			found = result !== null;
			if (!found) {
				const remainingString = sanitizedData.substring(firstBrace, lastBrace);
				lastBrace = remainingString.lastIndexOf('}');
				candidate = remainingString.substring(0, lastBrace + 1);
			}
		}

		return result;
	}

	testCandidate(candidate) {
		try {
			return JSON.parse(candidate);
		} catch (err) {
			return null;
		}
	}
}

export default JsonExtractor;
