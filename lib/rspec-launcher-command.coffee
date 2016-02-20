TerminalCommandRunner = require './terminal-command-runner'
JsonExtractor = require './json-extractor'
{Emitter} = require 'event-kit'

module.exports =
class RSpecLauncherCommand
  constructor: (
    emitter = new Emitter,
    jsonExtractor = new JsonExtractor,
    terminalCommandRunner = new TerminalCommandRunner) ->
    @emitter = emitter
    @jsonExtractor = jsonExtractor
    @terminalCommandRunner = terminalCommandRunner

  run: (file) ->
    @terminalCommandRunner.clean()

    rspecCommandPath = atom.config.get('rspec-tree-runner.rspecPathCommand')

    command = "#{rspecCommandPath} --format=json \"#{file}\""

    @terminalCommandRunner.onDataFinished (data) => @parseRSpecResult(data)

    @terminalCommandRunner.run(command, atom.project.getPaths()[0])

  onResultReceived: (callback) ->
    @emitter.on 'onResultReceived', callback

  parseRSpecResult: (data) ->
    if !!data.stdOutData
      jsonData = @jsonExtractor.extract(data.stdOutData)
    else
      jsonData = {}

    @emitter.emit 'onResultReceived', { result: jsonData, stdErrorData: data.stdErrorData }
