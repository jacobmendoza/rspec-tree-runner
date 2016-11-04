/** @babel */
module.exports = class JsonSanitizer {
  sanitize(data) {
    let charsToRemove = ['\r','\n','\b','\f','\t','\v'];

    for (let charToRemove of charsToRemove) {
      const regularExpression = new RegExp(charToRemove, 'g');
      data = data.replace(regularExpression, '');
    }

    return data;
  }
};
