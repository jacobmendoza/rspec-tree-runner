TreeBuilder = require '../lib/tree-builder'
AstParser = require '../lib/ast-parser'

describe 'TreeBuilder', ->
  [treeBuilder, astParser] = []

  beforeEach ->
    astParser = new AstParser
    treeBuilder = new TreeBuilder(astParser)
    spyOn(atom.notifications, "addError")


  it 'generates empty tree for null output', ->
    result = treeBuilder.buildFromStandardOutput(null)
    expect(result).toEqual({})

  it 'generates empty tree for undefined output', ->
    result = treeBuilder.buildFromStandardOutput(undefined)
    expect(result).toEqual({})

  it 'generates empty tree for invalid input', ->
    result = treeBuilder.buildFromStandardOutput('invalid input')
    expect(result).toEqual({})
    expect(atom.notifications.addError).toHaveBeenCalled()

  it 'generates tree with one node with one level input', ->
    input =
      type: "describe"
      identifier: "root"
      line: 12
      children: null

    inputString = JSON.stringify(input)

    result = treeBuilder.buildFromStandardOutput(inputString)[0]

    expect(result.type).toBe('describe')
    expect(result.text).toBe('root')
    expect(result.status).toBe(undefined)
    expect(result.line).toBe(12)
    expect(result.children).toEqual([])

  it 'generates tree with two nodes with two level input', ->
    input =
      type: "describe"
      identifier: "root"
      line: 12
      children: [{ type:"it", identifier:"something", line: 24, children: undefined }]

    inputString = JSON.stringify(input)

    result = treeBuilder.buildFromStandardOutput(inputString)[0]

    expect(result.type).toBe('describe')
    expect(result.text).toBe('root')
    expect(result.status).toBe(undefined)
    expect(result.line).toBe(12)
    expect(result.children[0].type).toBe('it')
    expect(result.children[0].text).toBe('something')
    expect(result.children[0].line).toBe(24)

  it 'updates the tree with tests results', ->
    testsResults =
      examples: [{description: "description", status: "failed", line_number: 24}]

    input =
      type: "describe"
      identifier: "root"
      line: 12
      children: [{ type:"it", identifier:"something", line: 24, children: undefined }]

    inputString = JSON.stringify(input)

    result = treeBuilder.buildFromStandardOutput(inputString)[0]

    treeBuilder.updateWithTests(testsResults)

    expect(result.status).toBe('failed')
    expect(result.children[0].status).toBe('failed')
