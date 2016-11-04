/** @babel */
import JsonExtractor from '../lib/json-extractor';
import JsonSanitizer from '../lib/json-sanitizer';

describe('JsonExtractor', () => {
  let extractor = {};
  let sanitizer = {};
  let jsonExample = '{"version":"3.4.2","examples":[{"description":"trying to break things"}]}';

  beforeEach(() => {
    sanitizer = new JsonSanitizer();
    extractor = new JsonExtractor(sanitizer);
  });

  it('returns empty object if no json in the string', () => {
    const input = 'no json here';
    spyOn(sanitizer, 'sanitize').andReturn(input);
    const output = extractor.extract(input);
    expect(output).toEqual({});
    expect(sanitizer.sanitize).toHaveBeenCalledWith(input);
  });

  it('returns object if clean json in the string', () => {
    spyOn(sanitizer, 'sanitize').andReturn(jsonExample);
    const output = extractor.extract(jsonExample);
    expect(output['version']).toBe('3.4.2');
    expect(sanitizer.sanitize).toHaveBeenCalledWith(jsonExample);
  });

  it('returns object if non-clean json in the string', () => {
    const input = `somethingbefore${jsonExample}somethingafter`;
    spyOn(sanitizer, 'sanitize').andReturn(input);
    const output = extractor.extract(input);
    expect(output['version']).toBe('3.4.2');
    expect(sanitizer.sanitize).toHaveBeenCalledWith(input);
  });

  it('returns object if two json in the string', () => {
    const input = `somethingbefore${jsonExample}somethingafter{\"secondJson\": 01}`;
    spyOn(sanitizer, 'sanitize').andReturn(input);
    const output = extractor.extract(input);
    expect(output['version']).toBe('3.4.2');
    expect(sanitizer.sanitize).toHaveBeenCalledWith(input);
  });

  it('returns object if multiple json in the string', () => {
    const input = `somethingbefore${jsonExample}somethingafter{\"secondJson\": 01}{\"third\": 01}`;
    spyOn(sanitizer, 'sanitize').andReturn(input);
    const output = extractor.extract(input);
    expect(output['version']).toBe('3.4.2');
    expect(sanitizer.sanitize).toHaveBeenCalledWith(input);
  });
});
