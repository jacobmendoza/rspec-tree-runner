JsonSanitizer = require '../lib/json-sanitizer'

describe 'JsonSanitizer', ->
  sanitizer = {}

  beforeEach ->
    sanitizer = new JsonSanitizer

  it 'removes break line characters', ->
    result = sanitizer.sanitize('some\ntext')
    expect(result).toBe('sometext')

    result = sanitizer.sanitize('some\r\ntext')
    expect(result).toBe('sometext')

  it 'removes other chars that should be escaped', ->
    result = sanitizer.sanitize('some\b\f\t\vtext')
    expect(result).toBe('sometext')
