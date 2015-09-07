RSpecLauncherCommand = require '../lib/rspec-launcher-command'
JsonSanitizer = require '../lib/json-sanitizer'
TerminalCommandRunner = require '../lib/terminal-command-runner'

describe 'RSpecLauncherCommand', ->
  [emitter, terminalCommandRunner, rspecLauncherCommand, jsonSanitizer] = []

  beforeEach ->
    emitter = {
      emit: ->
        undefined
    }

    spyOn(atom.project, 'getPaths').andReturn(['a', 'b'])

    atom.config.set('rspec-tree-runner.rspecPathCommand', 'rspec')

    jsonSanitizer = new JsonSanitizer

    terminalCommandRunner = new TerminalCommandRunner

    spyOn(terminalCommandRunner, 'run')

    spyOn(terminalCommandRunner, 'onDataFinished')

    spyOn(jsonSanitizer, 'sanitize').andReturn('{}')

    rspecLauncherCommand = new RSpecLauncherCommand(
      emitter,
      jsonSanitizer,
      terminalCommandRunner)

    rspecLauncherCommand.run('somefile')
    debugger
    rspecLauncherCommand.parseRSpecResult( { stdOutData: '{}', stdErrorData: '' })

  it 'runs the command', ->
    expect(terminalCommandRunner.run)
      .toHaveBeenCalledWith('rspec --format=json \"somefile\"', 'a')

  it 'calls the sanitizer when parsing data', ->
    expect(jsonSanitizer.sanitize)
      .toHaveBeenCalledWith('{}')
