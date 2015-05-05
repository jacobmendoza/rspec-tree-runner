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
      @h3 class: 'tree-view-title', ''
      @div class: 'tests-summary', =>
        @div class: 'tests-summary-container', =>
          @div class: 'tests-summary-passed', =>
            @div class: 'number', '-'
            @div class: 'text', 'passed'
          @div class: 'tests-summary-failed', =>
            @div class:'number', '-'
            @div class: 'text', 'failed'
          @div class: 'tests-summary-pending', =>
            @div class: 'number', '-'
            @div class: 'text', 'pending'
      @div class: 'rspec-tree-runner-view-container'

  initialize:  ->
    @currentState = new PluginState

    @currentState.onTreeBuilt (result) =>
      debugger
      @setStdErrorNotification(result.stdErrorData)
      @redrawTree(result.asTree, result.summary)

    @currentState.onSpecFileBeingAnalyzed =>
      @treeView.displayLoading('Spec file being analyzed') if @treeView?

    @currentState.onTestsRunning =>
      @treeView.displayLoading('RSpec running tests') if @treeView?

    @setCurrentAndCorrespondingFile(atom.workspace.getActiveTextEditor())

    @treeView = new TreeView

    this.find('.rspec-tree-runner-view-container').append(@treeView)

    @disposables = new CompositeDisposable

  setStdErrorNotification: (stdErrorData) ->
    return unless stdErrorData?

    return unless stdErrorData.length > 0

    if stdErrorData.length > 350
      stdErrorData = stdErrorData.substring(0, 350).concat("...")

    atom.notifications.addWarning("RSpec if running with warnings", { detail: stdErrorData });

  redrawTree: (asTree, summary) ->
    children = asTree || {}
    fileName = if children.length > 0 then @currentState.currentFileName else ''

    if @treeView?
      @treeView.setRoot({ label: 'root', children: children })
      @changeFile(fileName) if @treeView?
      @displayFile(true)
      @treeView.hideLoading()

      if summary?
        @updateSummary({
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

  changeFile: (fileName) ->
    title = this.find('.tree-view-title')
    title.show()
    title.text(fileName)

  displayFile: (display) ->
    title = this.find('.tree-view-title')
    if display then title.show() else title.hide()

  updateSummary: (summary) ->
    this.find('.tests-summary-passed .number').html(summary.passed)
    this.find('.tests-summary-failed .number').html(summary.failed)
    this.find('.tests-summary-pending .number').html(summary.pending)

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
