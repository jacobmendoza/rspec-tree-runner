/** @babel */
import JsonSanitizer from '../lib/json-sanitizer.js';

describe('JsonSanitizer', () => {
  let sanitizer;

  beforeEach(() => {
    sanitizer = new JsonSanitizer();
  });

  it('removes break line characters', () => {
    let result = sanitizer.sanitize('some\ntext');
    expect(result).toBe('sometext');
    result = sanitizer.sanitize('some\r\ntext');
    expect(result).toBe('sometext');
  });

  it('removes other chars that should be escaped', () => {
    const result = sanitizer.sanitize('some\b\f\t\vtext');
    expect(result).toBe('sometext');
  });
});
