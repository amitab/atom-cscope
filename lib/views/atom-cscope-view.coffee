{$, View} = require 'space-pen'
InputView = require './input-view'
ListView = require './list-view'

module.exports =
class AtomCscopeView extends View
  @content: ->
    @div class: "atom-cscope", =>
      @div class: "header", =>
        @div class: "inline-block spaced-item", =>
          @button class: "btn just-btn icon icon-zap", id: "refresh"
        @h4 class: "inline-block", "Atom Cscope"
        @h6 class: "inline-block", id: 'result-count', "0 results"
        @span class: 'loading loading-spinner-tiny inline-block no-show'
      @subview 'inputView', new InputView()
      @subview 'listView', new ListView()
  
  initialize: ->
    @on 'core:move-up', =>
      @listView.keyUsed = true
      @listView.selectPreviousItemView()
    @on 'core:move-down', =>
      @listView.keyUsed = true
      @listView.selectNextItemView()
    @on 'core:move-to-top', =>
      @listView.keyUsed = true
      @listView.selectFirstItemView()
    @on 'core:move-to-bottom', =>
      @listView.keyUsed = true
      @listView.selectLastItemView()
  
  clearItems: ->
    @listView.clearItems()
    
  applyResultSet: (@resultSet = []) ->
    @find('h6#result-count').text(resultSet.results.length + ' results')
    @listView.setItems(@resultSet.results)
    
  onSearch: (callback) ->
    @inputView.onSearch callback
      
  removeLoading: ->
    callback = => @find('span.loading').addClass('no-show')
    setTimeout callback, 600
  
  showLoading: ->
    callback = => @find('span.loading').removeClass('no-show')
    setTimeout callback, 10

  onResultClick: (callback) ->
    @listView.onConfirm callback

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element