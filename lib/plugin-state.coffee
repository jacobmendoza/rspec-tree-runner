RailsRSpecFinder = require './rails-rspec-finder'
RSpecAnalyzerCommand = require './rspec-analyzer-command'
{Emitter} = require 'event-kit'

module.exports =
class PluginState
  constructor: (
  emitter = new Emitter,
  railsRSpecFinder = new RailsRSpecFinder,
  rspecAnalyzerCommand = new RSpecAnalyzerCommand) ->
    @emitter = emitter
    @railsRSpecFinder = railsRSpecFinder
    @rspecAnalyzerCommand = rspecAnalyzerCommand

  set: (editor) ->
    if ((!editor) || (!editor.buffer))
      @currentFilePath = null
      @currentCorrespondingFilePath = null
      @specFileToAnalyze = null
      @specFileExists = null
    else
      @currentFilePath = editor.buffer.file.path

      currentFilePathExtension = @currentFilePath.split('.').pop();

      @currentCorrespondingFilePath = @railsRSpecFinder.toggleSpecFile(@currentFilePath)

      if @railsRSpecFinder.isSpec(@currentFilePath)
        @specFileToAnalyze = @currentFilePath
      else
        @specFileToAnalyze = @currentCorrespondingFilePath

      @currentFileName = @specFileToAnalyze.split("/").pop();

      @specFileExists = @railsRSpecFinder.fileExists(@specFileToAnalyze)

      @analyze(@specFileToAnalyze) if (@specFileToAnalyze? and @specFileExists)

      @rspecAnalyzerCommand.onDataParsed (asTree) =>
        @emitter.emit 'onTreeBuilt', asTree

  analyze: (file) ->
    @rspecAnalyzerCommand.run(file)

  onTreeBuilt: (callback) ->
    @emitter.on 'onTreeBuilt', callback
