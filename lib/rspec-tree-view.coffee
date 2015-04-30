{Disposable, CompositeDisposable} = require 'atom'
{View, $$} = require 'atom-space-pen-views'
{TreeView} = require './tree-view'
PluginState = require './plugin-state'

module.exports =
class RSpecTreeView extends View
  @content: ->
    @div class: 'rspec-tree-runner tool-panel focusable-panel', =>
      @div class: 'spec-does-not-exist', =>
        @h2 'It seems that this file doesn\'t have spec file'
        @h3 'Press ctrl-alt-q to create a new one'
        @div class: 'file-to-analyze'

  initialize:  ->
    @currentState = new PluginState

    @currentState.onTreeBuilt (result) =>
      @redrawTree(result.asTree, result.summary)

    @currentState.onSpecFileBeingAnalyzed =>
      @treeView.displayLoading('Spec file being analyzed') if @treeView?

    @currentState.onTestsRunning =>
      @treeView.displayLoading('RSpec running tests') if @treeView?

    @setCurrentAndCorrespondingFile(atom.workspace.getActiveTextEditor())

    @treeView = new TreeView

    @append(@treeView)

    @disposables = new CompositeDisposable

  redrawTree: (asTree, summary) ->
    children = asTree || {}
    fileName = if children.length > 0 then @currentState.currentFileName else ''

    if @treeView?
      @treeView.setRoot({ label: 'root', children: children })
      @treeView.changeFile(fileName) if @treeView?
      @treeView.displayFile(true)
      @treeView.hideLoading()

      if summary?
        @treeView.updateSummary({
          passed: summary.example_count - summary.failure_count,
          failed: summary.failure_count,
          pending: summary.pending_count
        })

  setCurrentAndCorrespondingFile: (editor) ->
    @currentState.set(editor)

    if @currentState.specFileExists
      this.find('.spec-does-not-exist').hide()
    else
      @redrawTree({})
      this.find('.spec-does-not-exist').show()
      @treeView.displayFile(false) if @treeView?

  handleEditorEvents: (editor) ->
    return unless editor

    @setCurrentAndCorrespondingFile(editor)

  runTests: ->
    return unless @currentState.specFileExists

    @currentState.runTests()

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

  detach: ->
    @disposables.dispose()
    @editorHandlers?.dispose()

  destroy: ->
    @detach()
