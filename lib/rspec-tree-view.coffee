{Disposable, CompositeDisposable} = require 'atom'
{View, $$} = require 'atom-space-pen-views'
RailsRSpecFinder = require './rails-rspec-finder'
PluginState = require './plugin-state'
# fs = require 'fs'

module.exports =
class RSpecTreeView extends View
  @content: ->
    @div class: 'rspec-tree-runner tool-panel focusable-panel', =>
      @div class: 'spec-does-not-exist', =>
        @h2 'It seems that this file doesn\'t have spec file'
        @h3 'Press ctrl-alt-q to create a new one'
        @div class: 'file-to-analyze'

  initialize: ->
    railsRSpecFinder = new RailsRSpecFinder(
      atom.project.getPaths()[0],
      atom.config.get('rspec-tree-runner.specSearchPaths'),
      atom.config.get('rspec-tree-runner.specDefaultPath'),
      fs)

    @currentState = new PluginState(railsRSpecFinder)

    @setCurrentAndCorrespondingFile(atom.workspace.getActiveTextEditor())

    @disposables = new CompositeDisposable

  setCurrentAndCorrespondingFile: (editor) ->
    @currentState.set(editor)

    if @currentState.specFileExists
      this.find('.spec-does-not-exist').hide()
    else
      this.find('.spec-does-not-exist').show()
      this.find('.file-to-analyze').html(@currentState.specFileToAnalyze)

  handleEditorEvents: (editor) ->
    return unless editor

    @setCurrentAndCorrespondingFile(editor)

  toggleSpecFile: ->
    atom.workspace.open(@currentState.currentCorrespondingFilePath) if @currentState.currentCorrespondingFilePath?

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
