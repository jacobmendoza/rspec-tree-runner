RailsRSpecFinder = require './rails-rspec-finder'
RSpecAnalyzerCommand = require './rspec-analyzer-command'
RSpecLauncherCommand = require './rspec-launcher-command'
TreeBuilder = require './tree-builder'

{Emitter} = require 'event-kit'

module.exports =
class PluginState
  constructor: (
  emitter = new Emitter,
  treeBuilder = new TreeBuilder,
  railsRSpecFinder = new RailsRSpecFinder,
  rspecAnalyzerCommand = new RSpecAnalyzerCommand,
  rspecLauncherCommand = new RSpecLauncherCommand) ->
    @emitter = emitter
    @treeBuilder = treeBuilder
    @railsRSpecFinder = railsRSpecFinder
    @rspecAnalyzerCommand = rspecAnalyzerCommand
    @rspecLauncherCommand = rspecLauncherCommand

  set: (editor) ->
    if ((!editor) || (!editor.buffer))
      @setNullState()
    else

      @cursor = editor.cursors[0]

      @currentFilePath = editor.buffer.file.path

      @currentFilePathExtension = @currentFilePath.split('.').pop();

      isNavigatingToCorresponding = @prevCorrespondingFilePath? and @prevCorrespondingFilePath == @currentFilePath

      @currentCorrespondingFilePath = @railsRSpecFinder.toggleSpecFile(@currentFilePath)

      @prevCorrespondingFilePath = @currentCorrespondingFilePath

      if !@currentCorrespondingFilePath?
        @setNullState()
        return

      if @railsRSpecFinder.isSpec(@currentFilePath)
        @specFileToAnalyze = @currentFilePath
      else
        @specFileToAnalyze = @currentCorrespondingFilePath

      @currentFileName = @specFileToAnalyze.split("/").pop();

      @specFileExists = @railsRSpecFinder.fileExists(@specFileToAnalyze)

      @specFileToAnalyzeWithoutProjectRoot = @railsRSpecFinder.getFileWithoutProjectRoot(@specFileToAnalyze) if @specFileToAnalyze?

      shouldAnalyze = @specFileToAnalyze? and @specFileExists and !isNavigatingToCorresponding

      @analyze(@specFileToAnalyze) if (shouldAnalyze)

      @rspecAnalyzerCommand.onDataParsed (dataReceived) =>
        asTree = @treeBuilder.buildFromStandardOutput(dataReceived)
        @emitter.emit 'onTreeBuilt', { asTree: asTree, summary: undefined, stdErrorData: undefined }

      @rspecLauncherCommand.onResultReceived (testsResults) =>
        @updateTreeWithTests(testsResults.result, testsResults.stdErrorData)

  setNullState: ->
    @currentFilePath = null
    @currentCorrespondingFilePath = null
    @specFileToAnalyze = null
    @specRowToAnalyze = null
    @specFileExists = null
    @specFileToAnalyzeWithoutProjectRoot = null

  analyze: (file) ->
    @emitter.emit 'onSpecFileBeingAnalyzed'
    @rspecAnalyzerCommand.run(file)

  runTests: ->
    return unless @specFileToAnalyze?

    return unless @specFileExists

    @emitter.emit 'onTestsRunning'

    @rspecLauncherCommand.run(@specFileToAnalyze)

  runSingleTest: ->
    return unless @specFileToAnalyze?

    return unless @specFileExists

    @specRowToAnalyze = @cursor.getBufferRow() + 1

    @emitter.emit 'onTestsRunning'

    @rspecLauncherCommand.run(@specFileToAnalyze + ":" + @specRowToAnalyze)

  updateTreeWithTests: (results, stdErrorData) ->
    asTree = @treeBuilder.updateWithTests(results)

    @emitter.emit 'onTreeBuilt', {
      asTree: asTree,
      summary: if results? then results.summary || undefined else undefined,
      stdErrorData: stdErrorData || ""
    }

  onTreeBuilt: (callback) ->
    @emitter.on 'onTreeBuilt', callback

  onSpecFileBeingAnalyzed: (callback) ->
    @emitter.on 'onSpecFileBeingAnalyzed', callback

  onTestsRunning: (callback) ->
    @emitter.on 'onTestsRunning', callback
