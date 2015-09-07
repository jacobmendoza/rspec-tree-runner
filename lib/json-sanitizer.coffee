module.exports =
  class JsonSanitizer
    sanitize: (data) ->
      charsToRemove = ['\r','\n','\b','\f','\t','\v']

      for charToRemove in charsToRemove
        regularExpression = new RegExp(charToRemove, 'g');
        data = data.replace(regularExpression, '');

      data
