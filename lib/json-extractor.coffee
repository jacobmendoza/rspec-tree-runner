JsonSanitizer = require './json-sanitizer'

module.exports =
  # Trying to address the problem of non-json text being inserted
  # into stdout when analysing the result of the RSpec test runner.
  # This happens when some gems (or even the user) write output
  # before, after or in the middle of the RSpec execution process,
  # even if the formatter being used is JSON an that makes the string
  # invalid.
  #
  # Despite it seems reasonable think that an implementation based
  # on a queue could be more efficient, I'm choosing the easiest solution
  # for now, trying to avoid some unexpected edge cases.
  #
  # As the JSON of the RSpec runner should be the first in the output,
  # assume '{' as the first character of the JSON that we want to extract,
  # find the last '}' and try to parse. If it fails, repeat the process
  # with the previous brace till succeeds or fails.
  #
  # Future improvements: Extract several JSON valid objects if they exist
  # and detect the one that belongs to RSpec runner output.
  class JsonExtractor
    constructor: (sanitizer = new JsonSanitizer) ->
      @sanitizer = sanitizer

    extract: (data) ->
      sanitizedData = @sanitizer.sanitize(data)

      firstBrace = sanitizedData.indexOf('{')
      lastBrace = sanitizedData.lastIndexOf('}')

      if (firstBrace == -1 or lastBrace == -1)
        return {}

      found = false

      candidate = sanitizedData.substring(firstBrace, lastBrace + 1)

      while !found and lastBrace isnt -1
        result = testCandidate candidate
        found = result != null
        if !found
          remainingString = sanitizedData.substring(firstBrace, lastBrace)
          lastBrace = remainingString.lastIndexOf('}')
          candidate = remainingString.substring(0, lastBrace + 1)

      return result

    testCandidate = (candidate) ->
      try
        JSON.parse(candidate)
      catch
        null
