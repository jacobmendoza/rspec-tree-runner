JsonExtractor = require '../lib/json-extractor'
JsonSanitizer = require '../lib/json-sanitizer'

describe 'JsonExtractor', ->
  extractor = {}
  sanitizer = {}
  jsonExample = '{"version":"3.4.2","examples":[{"description":"trying to break things"}]}'

  beforeEach ->
    sanitizer = new JsonSanitizer
    extractor = new JsonExtractor(sanitizer)

  it 'returns empty object if no json in the string', ->
    input = 'no json here'
    spyOn(sanitizer, 'sanitize').andReturn(input)
    output = extractor.extract(input)
    expect(output).toEqual({})
    expect(sanitizer.sanitize).toHaveBeenCalledWith(input)

  it 'returns object if clean json in the string', ->
    spyOn(sanitizer, 'sanitize').andReturn(jsonExample)
    output = extractor.extract(jsonExample)
    expect(output['version']).toBe('3.4.2')
    expect(sanitizer.sanitize).toHaveBeenCalledWith(jsonExample)

  it 'returns object if non-clean json in the string', ->
    input = "somethingbefore#{jsonExample}somethingafter"
    spyOn(sanitizer, 'sanitize').andReturn(input)
    output = extractor.extract(input)
    expect(output['version']).toBe('3.4.2')
    expect(sanitizer.sanitize).toHaveBeenCalledWith(input)

  it 'returns object if two json in the string', ->
    input = "somethingbefore#{jsonExample}somethingafter{\"secondJson\": 01}"
    spyOn(sanitizer, 'sanitize').andReturn(input)
    output = extractor.extract(input)
    expect(output['version']).toBe('3.4.2')
    expect(sanitizer.sanitize).toHaveBeenCalledWith(input)

  it 'returns object if multiple json in the string', ->
    input = "somethingbefore#{jsonExample}somethingafter{\"secondJson\": 01}{\"third\": 01}"
    spyOn(sanitizer, 'sanitize').andReturn(input)
    output = extractor.extract(input)
    expect(output['version']).toBe('3.4.2')
    expect(sanitizer.sanitize).toHaveBeenCalledWith(input)
