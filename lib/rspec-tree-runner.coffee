RspecTreeRunnerView = require './rspec-tree-runner-view'
{CompositeDisposable} = require 'atom'

module.exports =
  config:
    specSearchPaths:
      type: 'array'
      default: ['spec', 'fast_spec']
      items:
        type: 'string'
    specDefaultPath:
      type: 'string'
      default: 'spec'

  rspecTreeRunnerView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @rspecTreeRunnerView = new RspecTreeRunnerView(state.rspecTreeRunnerViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @rspecTreeRunnerView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'rspec-tree-runner:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @rspecTreeRunnerView.destroy()

  serialize: ->
    rspecTreeRunnerViewState: @rspecTreeRunnerView.serialize()

  toggle: ->
    console.log 'RspecTreeRunner was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
