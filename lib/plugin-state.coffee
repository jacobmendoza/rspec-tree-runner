RailsRSpecFinder = require './rails-rspec-finder'
RSpecAnalyzerCommand = require './rspec-analyzer-command'
RSpecLauncherCommand = require './rspec-launcher-command'
{Emitter} = require 'event-kit'

module.exports =
class PluginState
  constructor: (
  emitter = new Emitter,
  railsRSpecFinder = new RailsRSpecFinder,
  rspecAnalyzerCommand = new RSpecAnalyzerCommand,
  rspecLauncherCommand = new RSpecLauncherCommand) ->
    @emitter = emitter
    @railsRSpecFinder = railsRSpecFinder
    @rspecAnalyzerCommand = rspecAnalyzerCommand
    @rspecLauncherCommand = rspecLauncherCommand

  set: (editor) ->
    if ((!editor) || (!editor.buffer))
      @setNullState()
    else
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

      @rspecAnalyzerCommand.onDataParsed (asTree) =>
        @asTree = asTree
        @emitter.emit 'onTreeBuilt', { asTree: asTree, summary: undefined, stdErrorData: undefined }

      @rspecLauncherCommand.onResultReceived (testsResults) =>
        @updateTreeWithTests(testsResults.result, testsResults.stdErrorData)

  setNullState: ->
    @currentFilePath = null
    @currentCorrespondingFilePath = null
    @specFileToAnalyze = null
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

  updateTreeWithTests: (results, stdErrorData) ->
    shouldUpdateTree = results? and results.examples? and @asTree.length > 0

    @updateNode(@asTree[0], results) if shouldUpdateTree

    @emitter.emit 'onTreeBuilt', {
      asTree: @asTree,
      summary: if results? then results.summary || undefined else undefined,
      stdErrorData: stdErrorData || ""
    }

  updateNode: (node, testsResults) ->
    for child in node.children
      @updateNode(child, testsResults)

    if node.type == 'it' and node.line?
      for example in testsResults.examples
        if example.line_number == node.line
          node.exception = example.exception
          node.status = example.status
          node.withReport = if example.status == 'failed' then 'with-report' else ''
          break
    else
      finalStatus = true
      for child in node.children
        if child.status == 'failed'
          finalStatus = false
          break

      node.status = if finalStatus then 'passed' else 'failed'

  onTreeBuilt: (callback) ->
    @emitter.on 'onTreeBuilt', callback

  onSpecFileBeingAnalyzed: (callback) ->
    @emitter.on 'onSpecFileBeingAnalyzed', callback

  onTestsRunning: (callback) ->
    @emitter.on 'onTestsRunning', callback
