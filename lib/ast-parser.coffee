module.exports =
class AstParser
  parse: (data) ->
    if !data then return []

    @tree = []

    try
      jsonObject = JSON.parse(data)
      @addChildren(@tree, jsonObject)
    catch error
      console.log 'Error when parsing the following data'
      console.log data
      console.log error

    @tree

  addChildren: (result, currentOld) ->
    types = ['describe', 'context', 'it']

    if currentOld.type in types
      newNode = {
        type: currentOld.type
        text: currentOld.identifier
        line: currentOld.line
        status: undefined
        withReport: undefined
        children: []
      }

      result.push(newNode)

    for child in currentOld.children
      nextSubTree = if (newNode == undefined) then result else newNode.children
      @addChildren(nextSubTree, child)
