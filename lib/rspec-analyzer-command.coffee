TerminalCommandRunner = require './terminal-command-runner'
AstParser = require './ast-parser'
{Emitter} = require 'event-kit'

module.exports =
  class RSpecAnalyzerCommand
    constructor: (terminalCommandRunner) ->
      @emitter = new Emitter
      # @terminalCommandRunner = terminalCommandRunner

    run: (file) ->
      @terminalCommandRunner = new TerminalCommandRunner
      @astParser = new AstParser

      rubyPath = atom.config.get('rspec-tree-runner.rubyPath')

      rspecAnalyzerScript = atom.config.get('rspec-tree-runner.rspecAnalyzerScript')

      if !rspecAnalyzerScript?
        rspecAnalyzerScript = path.resolve(__dirname, '../spec-analyzer/spec_analyzer_script.rb')

      command = "#{rubyPath} #{rspecAnalyzerScript} #{file}"

      @terminalCommandRunner.onDataFinished (data) => @parseSTree(data)

      @terminalCommandRunner.run(command)

    onDataParsed: (callback) ->
      @emitter.on 'onDataParsed', callback

    parseSTree: (data) ->
      @asTree = @astParser.parse data.stdOutData
      @emitter.emit 'onDataParsed', @asTree
