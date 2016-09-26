RSpecLauncherCommand = require '../lib/rspec-launcher-command'
JsonSanitizer = require '../lib/json-extractor'
TerminalCommandRunner = require '../lib/terminal-command-runner'

describe 'RSpecLauncherCommand', ->
  [terminalCommandRunner, rspecLauncherCommand, jsonSanitizer] = []

  beforeEach ->
    spyOn(atom.project, 'getPaths').andReturn(['a', 'b'])

    atom.config.set('rspec-tree-runner.rspecPathCommand', 'rspec')

    jsonSanitizer = new JsonSanitizer

    terminalCommandRunner = new TerminalCommandRunner

    spyOn(terminalCommandRunner, 'run')

    spyOn(terminalCommandRunner, 'onDataFinished')

    spyOn(jsonSanitizer, 'extract').andReturn({})

    rspecLauncherCommand = new RSpecLauncherCommand(
      jsonSanitizer,
      terminalCommandRunner)

    rspecLauncherCommand.run('somefile')
    rspecLauncherCommand.parseRSpecResult( { stdOutData: '{}', stdErrorData: '' })

  it 'runs the command', ->
    expect(terminalCommandRunner.run)
      .toHaveBeenCalledWith('rspec --format=json \"somefile\"', 'a')

  it 'calls the sanitizer when parsing data', ->
    expect(jsonSanitizer.extract)
      .toHaveBeenCalledWith('{}')

  # it 'emits the result', ->
  #     expect(emitter.emit)
  #       .toHaveBeenCalledWith('onResultReceived', {result: {}, stdErrorData: ''})
