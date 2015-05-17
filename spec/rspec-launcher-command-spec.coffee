RSpecLauncherCommand = require '../lib/rspec-launcher-command'
TerminalCommandRunner = require '../lib/terminal-command-runner'

describe 'RSpecLauncherCommand', ->
  [emitter, terminalCommandRunner, rspecLauncherCommand] = []

  beforeEach ->
    emitter = {}

    spyOn(atom.project, 'getPaths').andReturn(['a', 'b'])

    atom.config.set('rspec-tree-runner.rspecPathCommand', 'rspec')

    terminalCommandRunner = new TerminalCommandRunner

    spyOn(terminalCommandRunner, 'run')

    spyOn(terminalCommandRunner, 'onDataFinished')

    rspecLauncherCommand = new RSpecLauncherCommand(emitter, terminalCommandRunner)

    rspecLauncherCommand.run('somefile')

  it 'runs the command', ->
    expect(terminalCommandRunner.run)
      .toHaveBeenCalledWith('rspec --format=json somefile', 'a')
