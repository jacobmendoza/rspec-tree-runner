{Disposable, CompositeDisposable} = require 'atom'
{View, $$} = require 'atom-space-pen-views'
{TreeView} = require './tree-view'

PluginState = require '../plugin-state'
RSpecTestDetails = require './rspec-test-details'
RailsRSpecFinder = require '../rails-rspec-finder'

module.exports =
class RSpecTreeView extends View
  @content: ->
    @div class: 'rspec-tree-runner tool-panel focusable-panel', =>
      @h3 class: 'tree-view-title', ''
      @div class: 'spec-does-not-exist', =>
        @h2 'It seems that this file doesn\'t have spec file'
        @h3 class:'toggle-file-hint', ''
        @div class: 'file-to-analyze'
      @div class: 'not-ruby-file', =>
        @h2 'It seems that this is not a ruby file'
        @h3 'The file must have the extension .rb'
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
      @h3 class: 'run-tests-hint hint', ''
      @h3 class: 'run-single-test-hint hint', ''
      @h3 class: 'toggle-file-hint hint', ''
      @div class: 'rspec-tree-runner-view-container'

  initialize:  ->
    @treeView = new TreeView

    @treeView.onReportClicked ({item}) =>
      if item.exception?
        @rspecTestDetails.setVisible(true)
        @rspecTestDetails.setContent(item.exception)

    this.find('.rspec-tree-runner-view-container').append(@treeView)

    @disposables = new CompositeDisposable

  setStdErrorNotification: (result) ->
    return unless result.stdErrorData?

    return unless result.stdErrorData.length > 0

    size = atom.config.get('rspec-tree-runner.sizeOfRSpecMessageStrings')

    showWarnings = atom.config.get('rspec-tree-runner.showRSpecWarningMessages')

    dataToDisplay = result.stdErrorData

    if result.stdErrorData.length > size
      dataToDisplay = result.stdErrorData.substring(0, size).concat("...")

    if result.summary?
      atom.notifications.addWarning("RSpec is running with warnings", { detail: dataToDisplay }) if showWarnings
    else
      atom.notifications.addError("RSpec has failed", { detail: dataToDisplay });

  redrawTree: (asTree, testsResults) ->
    children = asTree || {}

    if @treeView?
      @treeView.setRoot({ label: 'root', children: children })
      @displayFile(true)
      @treeView.hideLoading()

      if testsResults? and testsResults.summary?
        @updateSummary({
          passed: testsResults.summary.example_count - testsResults.summary.failure_count,
          failed: testsResults.summary.failure_count,
          pending: testsResults.summary.pending_count
        })

  setInitialUI: ->
    this.find('.run-tests-hint').hide()
    this.find('.run-single-test-hint').hide()
    this.find('h3.toggle-file-hint').hide()

  setUiForSpecFileExists: ->
    this.find('.spec-does-not-exist').hide()
    this.find('.tests-summary').show()
    this.find('.run-tests-hint').show()
    this.find('.run-single-test-hint').show()
    this.find('h3.toggle-file-hint').show()

  setUiForSpecFileNotExists: ->
    @redrawTree({})
    this.find('.spec-does-not-exist').show()
    this.find('.spec-does-not-exist .toggle-file-hint').show()
    this.find('.tests-summary').hide()
    @treeView.hide if @treeView?

  setUiForRubyFile: (fileName) ->
    this.find('.not-ruby-file').hide()
    this.find('.rspec-tree-runner-view-container').show()
    @changeFile(fileName)

  setUiForNonRubyFileMessage: ->
    this.find('.not-ruby-file').show()
    this.find('.spec-does-not-exist').hide()
    this.find('.tests-summary').hide()
    this.find('.rspec-tree-runner-view-container').hide()
    this.find('.tree-view-title').hide()
    this.find('.run-tests-hint').hide()
    this.find('.run-single-test-hint').hide()
    this.find('h3.toggle-file-hint').hide()
    return

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

  displayLoadingMessage: (text) ->
    @treeView.displayLoading(text) if @treeView?

  toggleSpecFile: (destinationFileName) ->
    atom.workspace.open(destinationFileName) if destinationFileName?

  toggle: ->
    return unless @panel

    if @panel.isVisible()
      @panel.hide()
    else
      @panel.show()

  attach: ->
    @rspecTestDetails = new RSpecTestDetails

    @panel = atom.workspace.addRightPanel(item: this, visible: false)

    @prepareKeyStrokesText()

    @disposables.add new Disposable =>
      @panel.destroy()
      @panel = null

    @disposables.add new Disposable =>
      @rspecTestDetails.panel.destroy()
      @rspecTestDetails.panel = null

  prepareKeyStrokesText: ->
    toggleSpecFileKeyBindings = atom.keymaps.findKeyBindings({command:'rspec-tree-runner:toggle-spec-file' })
    runTestsKeyBindings = atom.keymaps.findKeyBindings({command:'rspec-tree-runner:run-tests' })
    runSingleTestKeyBindings = atom.keymaps.findKeyBindings({command:'rspec-tree-runner:run-single-test' })

    toggleSpecFileKeyStroke = if (toggleSpecFileKeyBindings and toggleSpecFileKeyBindings.length > 0) then toggleSpecFileKeyBindings[0].keystrokes else 'not def'

    runTestsKeyStroke = if (runTestsKeyBindings and runTestsKeyBindings.length > 0) then runTestsKeyBindings[0].keystrokes else 'not def'
    runSingleTestKeyStroke = if (runSingleTestKeyBindings and runSingleTestKeyBindings.length > 0) then runSingleTestKeyBindings[0].keystrokes else 'not def'

    this.find('h3.toggle-file-hint').html("Press #{toggleSpecFileKeyStroke} to toggle/create")
    this.find('h3.run-tests-hint').html("Press #{runTestsKeyStroke} to run tests")
    this.find('h3.run-single-test-hint').html("Press #{runSingleTestKeyStroke} to run a single test")

  detach: ->
    @disposables.dispose()
    @editorHandlers?.dispose()

  destroy: ->
    @detach()
