{$, $$, View, ScrollView} = require 'atom-space-pen-views'
{Emitter} = require 'event-kit'

module.exports =
  TreeNode: class TreeNode extends View
    @content: ({text, children, status}) ->
      if children
        @li class: 'list-nested-item list-selectable-item', =>
          @div class: "list-item #{status}", =>
            @span text
          @ul class: 'list-tree', =>
            for child in children
              @subview 'child', new TreeNode(child)
      else
        @li class: 'list-item list-selectable-item', =>
          @span text

    initialize: (item) ->
      @emitter = new Emitter
      @item = item
      @item.view = this

      @on 'dblclick', @dblClickItem
      @on 'click', @clickItem

    setCollapsed: ->
      @toggleClass('collapsed') if @item.children

    setSelected: ->
      @addClass('selected')
      setTimeout (=> @removeClass('selected')), 150

    onDblClick: (callback) ->
      @emitter.on 'on-dbl-click', callback
      if @item.children
        for child in @item.children
          child.view.onDblClick callback

    onSelect: (callback) ->
      @emitter.on 'on-select', callback
      if @item.children
        for child in @item.children
          child.view.onSelect callback

    clickItem: (event) =>
      if @item.children
        selected = @hasClass('selected')
        @removeClass('selected')
        $target = @find('.list-item:first')
        left = $target.position().left
        right = $target.children('span').position().left
        width = right - left
        @toggleClass('collapsed') if event.offsetX <= width
        @addClass('selected') if selected
        return false if event.offsetX <= width

      @emitter.emit 'on-select', {node: this, item: @item}
      return false

    dblClickItem: (event) =>
      @emitter.emit 'on-dbl-click', {node: this, item: @item}
      return false


  TreeView: class TreeView extends ScrollView
    @content: ->
      @div class: 'rspec-tree-runner-tree-view', =>

        @div class: 'tree-view-updating', =>
          @div class: 'x', =>
            @div class: 'tree-view-updating-spinner'
            @div class: 'tree-view-updating-text', ''
        @ul class: 'list-tree has-collapsable-children', outlet: 'root'


    initialize: ->
      super
      @title = ''
      @emitter = new Emitter

    displayLoading: (text) ->
      console.log 'displayLoading'
      this.find('.tree-view-updating').show()
      e = this.find('.tree-view-updating .tree-view-updating-text')
      e.html("Running tests")
      elem = this.find('.list-tree.has-collapsable-children')
      elem.css("opacity", "0.1")
      # loadingDiv = this.find('.tree-view-updating')
      # loadingText = this.find('.tree-view-updating-text')
      # loadingDiv.show()
      # loadingText.html(text)

    hideLoading: ->
      console.log 'hideLoading'
      this.find('.tree-view-updating').hide()
      elem = this.find('.list-tree.has-collapsable-children')
      elem.css("opacity", "1")
      # elem.removeClass("loading")
      # loadingDiv = this.find('.tree-view-updating')
      # loadingText = this.find('.tree-view-updating-text')
      # loadingDiv.hide()
      # loadingText.html('')

    deactivate: ->
      @remove()

    onSelect: (callback) =>
      @emitter.on 'on-select', callback

    setRoot: (root, ignoreRoot=true) ->
      @rootNode = new TreeNode(root)

      @rootNode.onDblClick ({node, item}) =>
        node.setCollapsed()
      @rootNode.onSelect ({node, item}) =>
        @clearSelect()
        node.setSelected()
        @emitter.emit 'on-select', {node, item}

      @root.empty()
      @root.append $$ ->
        @div =>
          if ignoreRoot
            for child in root.children
              @subview 'child', child.view
          else
            @subview 'root', @rootNode

    traversal: (root, doing) =>
      doing(root.item)
      if root.item.children
        for child in root.item.children
          @traversal(child.view, doing)

    toggleTypeVisible: (type) =>
      @traversal @rootNode, (item) =>
        if item.type == type
          item.view.toggle()

    clearSelect: ->
      $('.list-selectable-item').removeClass('selected')

    select: (item) ->
      @clearSelect()
      item?.view.setSelected()
