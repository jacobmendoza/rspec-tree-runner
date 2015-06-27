TerminalCommandRunner = require './terminal-command-runner'
{Emitter} = require 'event-kit'
path = require 'path'

module.exports =
  class RSpecAnalyzerCommand
    constructor: (
    emitter = new Emitter,
    terminalCommandRunner = new TerminalCommandRunner,
    systemPath = path)  ->
      @emitter = emitter
      @terminalCommandRunner = terminalCommandRunner
      @path = systemPath

    run: (file) ->
      @terminalCommandRunner.clean()

      rubyPath = atom.config.get('rspec-tree-runner.rubyPathCommand')

      rspecAnalyzerScript = atom.config.get('rspec-tree-runner.rspecAnalyzerScript')

      if !rspecAnalyzerScript?
        rspecAnalyzerScript = @path.resolve(__dirname, '../spec-analyzer/spec_analyzer_script.rb')

      command = "#{rubyPath} #{rspecAnalyzerScript} \"#{file}\""

      @terminalCommandRunner.onDataFinished (data) => @parseData(data)

      @terminalCommandRunner.run(command)

    onDataParsed: (callback) ->
      @emitter.on 'onDataParsed', callback

    parseData: (data) ->
      @emitter.emit 'onDataParsed', data.stdOutData
