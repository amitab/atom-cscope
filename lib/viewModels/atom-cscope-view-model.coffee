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

    @ractive.on 'search-force', (event) =>
      newSearch = @view.getSearchParams()
      @performSearch newSearch
    @ractive.on 'path-select', (event) =>
      @view.input.focus()

    @view.onConfirm (event) =>
      newSearch = @view.getSearchParams()
      if @arrowsUsed and @sameAsPreviousSearch newSearch
        @openResult @view.currentSelection
      else
        @performSearch newSearch

    @subscriptions.add atom.config.observe 'atom-cscope.LiveSearch', (newValue) =>
      if not newValue
        @liveSearchListener?.dispose()
        return

      @liveSearchListener = @view.input.getModel().onDidStopChanging () =>
        return unless newValue
        newSearch = @view.getSearchParams()
        @performSearch newSearch

  invokeSearch: (option, keyword) ->
    @view.autoFill option, keyword
    newSearch = @view.getSearchParams()
    @performSearch newSearch

  performSearch: (newSearch) ->
    if @searchCallback?
      promise = @searchCallback newSearch
      @view.startLoading()
      promise.then @view.stopLoading
    else
      console.log "searchCallback not found."
    @arrowsUsed = false
    @previousSearch = newSearch
    @view.input.focus()

  sameAsPreviousSearch: (newSearch) ->
    return _.isEqual(newSearch, @previousSearch)

  resetSearch: () ->
    @previousSearch =
      keyword: null
      option: null
      path: null

  openResult: (index) ->
    @resultClickCallback @model.data.results[index]

  onResultClick: (callback) ->
    @resultClickCallback = callback
    @ractive.on 'result-click', (event) =>
      temp = event.resolve().split(".")
      model = @model.data.results[parseInt temp.pop()]
      @resultClickCallback model
      @view.selectItemView
      
  onRefresh: (callback) ->
    @ractive.on 'refresh', (event) =>
      callback event
      @view.input.focus()

  onSearch: (callback) ->
    @searchCallback = callback