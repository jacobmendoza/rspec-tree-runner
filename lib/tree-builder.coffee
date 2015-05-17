AstParser = require './ast-parser'

module.exports =
  class TreeBuilder
    constructor: (astParser = new AstParser) ->
      @astParser = astParser

    buildFromStandardOutput: (standardOutput) ->
      return {} unless standardOutput

      try
        @asTree = @astParser.parse standardOutput
        @asTree
      catch error
        atom.notifications.addError("Can't parse this RSpec file. Please check errors.");
        return {}

    updateWithTests: (results) ->
      shouldUpdateTree = results? and results.examples? and @asTree.length > 0

      @updateNode(@asTree[0], results) if shouldUpdateTree

      @asTree

    updateNode: (node, testsResults) ->
      for child in node.children
        @updateNode(child, testsResults)

      if node.type == 'it' and node.line?
        for example in testsResults.examples
          if example.line_number == node.line
            node.exception = example.exception
            node.status = example.status
            node.withReport = if example.status == 'failed' then 'with-report' else ''
            break
      else
        finalStatus = true
        for child in node.children
          if child.status == 'failed'
            finalStatus = false
            break

        node.status = if finalStatus then 'passed' else 'failed'
