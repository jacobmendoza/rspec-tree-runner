TerminalCommandRunner = require './terminal-command-runner'
JsonSanitizer = require './json-sanitizer'
{Emitter} = require 'event-kit'

module.exports =
class RSpecLauncherCommand
  constructor: (
    emitter = new Emitter,
    jsonSanitizer = new JsonSanitizer,
    terminalCommandRunner = new TerminalCommandRunner) ->
    @emitter = emitter
    @jsonSanitizer = jsonSanitizer
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
      sanitizedData = @jsonSanitizer.sanitize(data.stdOutData)
      jsonData = JSON.parse(sanitizedData)
    else
      jsonData = {}

    @emitter.emit 'onResultReceived', { result: jsonData, stdErrorData: data.stdErrorData }
