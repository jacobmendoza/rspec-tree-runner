RSpecAnalyzerCommand = require '../lib/rspec-analyzer-command'
TerminalCommandRunner = require '../lib/terminal-command-runner'
AstParser = require '../lib/ast-parser'

describe 'RSpecAnalyzerCommand', ->
  [fakePath, emitter, command, terminalCommandRunner] = []

  beforeEach ->
    emitter: {}
    fakePath = { resolve: {} }
    atom.config.set('rspec-tree-runner.rubyPathCommand', 'ruby')

    terminalCommandRunner = new TerminalCommandRunner

    astParser = new AstParser

    spyOn(terminalCommandRunner, 'onDataFinished')

    spyOn(terminalCommandRunner, 'run')

    spyOn(astParser, 'parse').andReturn([])

    command = new RSpecAnalyzerCommand(
      emitter, terminalCommandRunner, astParser, fakePath)

  describe 'if no analyzer path is supplied', ->
    it 'gets path from filesystem and calls runner', ->
      atom.config.set('rspec-tree-runner.rspecAnalyzerScript', undefined)

      spyOn(fakePath, 'resolve').andReturn('route_to_script/spec_analyzer_script.rb');

      command.run('somefile')

      expect(terminalCommandRunner.run).toHaveBeenCalledWith('ruby route_to_script/spec_analyzer_script.rb somefile')

  describe 'if analyzer path is supplied', ->
    it 'gets path from configuration and calls runner', ->
      atom.config.set('rspec-tree-runner.rspecAnalyzerScript', 'custom_route/spec_analyzer_script.rb')

      command.run('somefile')

      expect(terminalCommandRunner.run).toHaveBeenCalledWith('ruby custom_route/spec_analyzer_script.rb somefile')
