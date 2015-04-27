module.exports =
class AstParser
  parse: (data) ->
    @tree = []
    jsonObject = JSON.parse(data)
    @addChildren(@tree, jsonObject)
    @tree

  addChildren: (result, currentOld) ->
    types = ['describe', 'context', 'it']

    if currentOld.type in types
      newNode = {
        type: currentOld.type
        text: currentOld.identifier
        line: currentOld.line
        status: 'success'
        children: []
      }

      result.push(newNode)

    for child in currentOld.children
      nextSubTree = if (newNode == undefined) then result else newNode.children
      @addChildren(nextSubTree, child)
