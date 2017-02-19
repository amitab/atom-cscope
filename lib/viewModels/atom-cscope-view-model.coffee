{allowUnsafeNewFunction} = require 'loophole'
Ractive = require 'ractive'
keys = require 'ractive-events-keys'
{CompositeDisposable} = require 'atom'
_ = require 'underscore-plus'

module.exports =
class AtomCscopeViewModel
  constructor: (@view, @model) ->
    @subscriptions = new CompositeDisposable
    @arrowsUsed = false
    @previousSearch =
      keyword: null
      option: null
      path: null
    @ractive = allowUnsafeNewFunction =>
      new Ractive
        el: @view.target
        data: @model.data
        template: @view.template.toString()
        events:
          escape: keys.escape
          enter: keys.enter
          up: keys.uparrow
          down: keys.downarrow

    @view.initilaize()
    @setupEvents()

  setupEvents: () ->
    @model.onDataChange (itemName, newItem) =>
      @ractive.set itemName, newItem
      
    @model.onDataUpdate (itemName, newItem) =>
      @ractive.merge itemName, newItem
      
    @view.onMoveUp (event) =>
      @arrowsUsed = true
      @view.selectPrev()
      
    @view.onMoveDown (event) =>
      @arrowsUsed = true
      @view.selectNext()
      
    @view.onMoveToTop (event) =>
      @arrowsUsed = true
      @view.selectFirst()
      
    @view.onMoveToBottom (event) =>
      @arrowsUsed = true
      @view.selectLast()
      
    @view.onConfirm (event) =>
      newSearch = @view.getSearchParams()
      if @arrowsUsed and @sameAsPreviousSearch newSearch
        console.log 'OPENING FILE'
      else
        @arrowsUsed = false
        @previousSearch = newSearch
        if @searchCallback? then @searchCallback newSearch else console.log "searchCallback not found."

  sameAsPreviousSearch: (newSearch) ->
    return _.isEqual(newSearch, @previousSearch)

  resetSearch: () ->
    @previousSearch =
      keyword: null
      option: null
      path: null

  onToggle: (callback) ->
    @view.onToggle callback

  onResultClick: (callback) ->
    @ractive.on 'result-click', callback
      
  onRefresh: (callback) ->
    @ractive.on 'refresh', callback

  onSearch: (callback) ->
    @searchCallback = callback