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
      
    @ractive.on 'move-up', (event) =>
      @arrowsUsed = true
      @view.selectPrev()

    @ractive.on 'move-down', (event) =>
      @arrowsUsed = true
      @view.selectNext()
      
    @ractive.on 'confirm', (event) =>
      newSearch = @view.getSearchParams()
      if @arrowsUsed and @sameAsPreviousSearch newSearch
        console.log 'OPENING FILE'
      else
        console.log "SEARCH"
        @arrowsUsed = false
        @updateSearch newSearch
        @searchCallback newSearch

  sameAsPreviousSearch: (newSearch) ->
    return _.isEqual(search, @previousSearch)
    
  updateSearch: (newSearch) ->
    @previousSearch = newSearch

  resetSearch: () ->
    @previousSearch =
      keyword: null
      option: null
      path: null

  onSearch: (callback) ->
    @searchCallback = callback