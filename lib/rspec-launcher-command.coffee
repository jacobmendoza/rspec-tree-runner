TerminalCommandRunner = require './terminal-command-runner'
{Emitter} = require 'event-kit'

module.exports =
class RSpecLauncherCommand
  constructor: (emitter = new Emitter, terminalCommandRunner = new TerminalCommandRunner) ->
    @emitter = emitter
    @terminalCommandRunner = terminalCommandRunner

  run: (file) ->
    @terminalCommandRunner.clean()

    rspecCommandPath = atom.config.get('rspec-tree-runner.rspecPathCommand')

    command = "#{rspecCommandPath} #{file}"

    @terminalCommandRunner.onDataFinished (data) => @parseRSpecResult(data)

    @terminalCommandRunner.run(command, atom.project.getPaths()[0])

  onResultReceived: (callback) ->
    @emitter.on 'onResultReceived', callback

  parseRSpecResult: (data) ->
    jsonData = if !!data.stdOutData then JSON.parse(data.stdOutData) else {}
    @emitter.emit 'onResultReceived', { result: jsonData, stdErrorData: data.stdErrorData }
