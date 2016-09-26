{Disposable, CompositeDisposable} = require 'atom'
{View, $$} = require 'atom-space-pen-views'

module.exports =
class RSpecTestDetails extends View
  @content: ->
    @div class: 'rspec-test-details', =>
      @h1 'Test details'
      @div class: 'message'
      @div class: 'backtrace', =>
        @div class: 'backtrace-text'
      @button 'Close', class: 'btn', click: 'close'

  initialize: ->
    @panel = atom.workspace.addModalPanel(item: this, visible:false)

  setContent: (exception) ->
    this.find('.message').html(exception.message)
    this.find('.backtrace-text').html(exception.backtrace)

  setVisible: (visible) ->
    if visible then @panel.show() else @panel.hide()

  close: ->
    @panel.hide()
