/** @babel */
class JsonSanitizer {
	sanitize(data) {
		const charsToRemove = ['\r', '\n', '\b', '\f', '\t', '\v'];

		for (const charToRemove of charsToRemove) {
			const regularExpression = new RegExp(charToRemove, 'g');
			data = data.replace(regularExpression, '');
		}

		return data;
	}
}

export default JsonSanitizer;
