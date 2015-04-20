{Disposable, CompositeDisposable} = require 'atom'
{View, $$} = require 'atom-space-pen-views'
RailsRSpecFinder = require './rails-rspec-finder'
fs = require 'fs'

module.exports =
class RSpecTreeView extends View
  @content: ->
    @div class: 'rspec-tree-runner tool-panel focusable-panel', =>
      @div class: 'spec-does-not-exist', =>
        @h2 'It seems that this file doesn\'t have spec file'
        @h3 'Press ctrl-alt-c to create a new one'
        @div class: 'file-to-analyze'

  initialize: ->
    @currentFilePath = null
    @currentCorrespondingFilePath = null
    @specFileToAnalyze = null

    @railsRSpecFinder = new RailsRSpecFinder(
      atom.project.getPaths()[0],
      atom.config.get('rspec-tree-runner.specSearchPaths'),
      atom.config.get('rspec-tree-runner.specDefaultPath'),
      fs)

    @setCurrentAndCorrespondingFile(atom.workspace.getActiveTextEditor())

    @disposables = new CompositeDisposable

  setCurrentAndCorrespondingFile: (editor) ->
    return unless editor.buffer

    @currentFilePath = editor.buffer.file.path

    currentFilePathExtension = @currentFilePath.split('.').pop();

    @currentCorrespondingFilePath = @railsRSpecFinder.toggleSpecFile(@currentFilePath)

    if @railsRSpecFinder.isSpec(@currentFilePath)
      @specFileToAnalyze = @currentFilePath
    else
      @specFileToAnalyze = @currentCorrespondingFilePath

    if @railsRSpecFinder.fileExists(@specFileToAnalyze)
      this.find('.spec-does-not-exist').hide()
    else
      this.find('.spec-does-not-exist').show()
      this.find('.file-to-analyze').html(@railsRSpecFinder.getFileWithoutProjectRoot(@specFileToAnalyze))

  createSpecFile: (editor) ->
    atom.workspace.open(@specFileToAnalyze)

  handleEditorEvents: (editor) ->
    return unless editor

    @setCurrentAndCorrespondingFile(editor)

  toggleSpecFile: ->
    fileToToggle = @railsRSpecFinder.toggleSpecFile(@currentFilePath)

    atom.workspace.open(fileToToggle) if fileToToggle?

  toggle: ->
    return unless @panel

    if @panel.isVisible()
      @panel.hide()
    else
      @panel.show()

  attach: ->
    @panel = atom.workspace.addRightPanel(item: this, visible: false)

    @disposables.add new Disposable =>
      @panel.destroy()
      @panel = null

    @disposables.add atom.workspace.onDidChangeActivePaneItem (editor) =>
      @handleEditorEvents(editor)
