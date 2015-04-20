RailsRSpecFinder = require './rails-rspec-finder'

module.exports =
class PluginState
  constructor: (railsRSpecFinder) ->
    @railsRSpecFinder = railsRSpecFinder

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

      @specFileExists = @railsRSpecFinder.fileExists(@specFileToAnalyze)
