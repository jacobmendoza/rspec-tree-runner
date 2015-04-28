{Emitter} = require 'event-kit'
ChildProcess = require 'child_process'

module.exports =
class TerminalCommandRunner
  constructor: ->
    @emitter = new Emitter
    @stdOutData = ''
    @stdErrorData = ''
  run: (command, destinyFolder = null) ->
    @command = command
    @destinyFolder = destinyFolder

    spawn = ChildProcess.spawn

    terminal = spawn("bash", ["-l"])
    terminal.on 'close', @onClose
    terminal.stdout.on 'data', @onStdOut
    terminal.stderr.on 'data', @onStdErr

    terminalCommand = if @destinyFolder then "cd #{@destinyFolder} && #{@command}\n" else "#{@command}\n"

    console.log "Launching command to terminal: #{terminalCommand}"

    terminal.stdin.write(terminalCommand)

    terminal.stdin.write("exit\n")

  onDataReceived: (callback) ->
    @emitter.on 'onData', callback

  onDataFinished: (callback) ->
    @emitter.on 'onFinishData', callback

  onStdOut: (newData) =>
    @stdOutData = @stdOutData.concat(newData.toString())
    @emitter.emit 'onStdOutData', @stdOutData

  onStdErr: (newData) =>
    @stdErrorData = @stdErrorData.concat(newData.toString())
    @emitter.emit 'onData', @stdErrorData

  onClose: (code) =>
    @emitter.emit 'onFinishData', { stdOutData: @stdOutData, stdErrorData: @stdErrorData }
