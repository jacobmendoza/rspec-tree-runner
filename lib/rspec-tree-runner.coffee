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
  mainView: null
  subscriptions: null

  activate: (state) ->
    @mainView = @getView()
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'rspec-tree-runner:toggle': => @mainView.toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'rspec-tree-runner:toggle-spec-file': => @mainView.toggleSpecFile()
    @subscriptions.add atom.commands.add 'atom-workspace', 'rspec-tree-runner:create-spec-file': => @mainView.createSpecFile()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @rspecTreeRunnerView.destroy()

  serialize: ->
    rspecTreeRunnerViewState: @rspecTreeRunnerView.serialize()

  getView: ->
    unless @view
      RSpecTreeView = require './rspec-tree-view'
      @view = new RSpecTreeView()
      @view.attach()
    @view
