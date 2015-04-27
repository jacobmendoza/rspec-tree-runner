TerminalCommandRunner = require './terminal-command-runner'
AstParser = require './ast-parser'
{Emitter} = require 'event-kit'
path = require 'path'

module.exports =
  class RSpecAnalyzerCommand
    constructor: (
    emitter = new Emitter,
    terminalCommandRunner = new TerminalCommandRunner,
    astParser = new AstParser
    systemPath = path)  ->
      @emitter = emitter
      @terminalCommandRunner = terminalCommandRunner
      @path = systemPath
      @astParser = astParser

    run: (file) ->
      rubyPath = atom.config.get('rspec-tree-runner.rubyPath')

      rspecAnalyzerScript = atom.config.get('rspec-tree-runner.rspecAnalyzerScript')

      if !rspecAnalyzerScript?
        rspecAnalyzerScript = @path.resolve(__dirname, '../spec-analyzer/spec_analyzer_script.rb')

      command = "#{rubyPath} #{rspecAnalyzerScript} #{file}"

      @terminalCommandRunner.onDataFinished (data) => @parseSTree(data)

      @terminalCommandRunner.run(command)

    onDataParsed: (callback) ->
      @emitter.on 'onDataParsed', callback

    parseSTree: (data) ->
      @asTree = @astParser.parse data.stdOutData
      @emitter.emit 'onDataParsed', @asTree
