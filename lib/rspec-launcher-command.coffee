TerminalCommandRunner = require './terminal-command-runner'
{Emitter} = require 'event-kit'

module.exports =
class RSpecLauncherCommand
  constructor: (emitter = new Emitter, terminalCommandRunner = new TerminalCommandRunner) ->
    @emitter = emitter
    @terminalCommandRunner = terminalCommandRunner

  run: (file) ->
    rspecCommandPath = atom.config.get('rspec-tree-runner.rspecPathCommand')

    command = "#{rspecCommandPath} #{file}"

    @terminalCommandRunner.onDataFinished (data) => @parseRSpecResult(data)

    @terminalCommandRunner.run(command, atom.project.getPaths()[0])

  onResultReceived: (callback) ->
    @emitter.on 'onResultReceived', callback

  parseRSpecResult: (data) ->
    @emitter.emit 'onResultReceived', data
