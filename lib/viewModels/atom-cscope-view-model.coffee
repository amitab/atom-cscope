{allowUnsafeNewFunction} = require 'loophole'
Ractive = require 'ractive'

AtomCscopeView = require '../views/atom-cscope-view'
AtomCscopeModel = require '../models/atom-cscope-model'

module.exports =
class AtomCscopeViewModel
  view: null
  model: null
  subscriptions: null
  modalPanel: null
  previousSearch:
    keyword: null
    option: null
    path: null
  ractive: null

  constructor: (subscriptions) ->
    @model = new AtomCscopeModel subscriptions
    @view = new AtomCscopeView subscriptions
    window.x = @
    @subscriptions = subscriptions
    @attachModal()
    @initilaize()

  initilaize: () ->
    @ractive = allowUnsafeNewFunction =>
      new Ractive
        el: @view.target
        data: @model.data
        template: @view.template.toString()

    @view.initilaize()
    @setupEvents()

  attachModal: () ->
    atom.config.observe 'atom-cscope.WidgetLocation', (event) =>
      wasVisible = if @modalPanel?.isVisible() then true else false
      @modalPanel?.destroy()
      @addPanel()
      if @modalPanel? then @show() if wasVisible
    return @modalPanel

  addPanel: () ->
    switch atom.config.get('atom-cscope.WidgetLocation')
      when 'bottom' then @modalPanel = atom.workspace.addBottomPanel(item: @view.getElement(), visible: false)
      when 'top' then @modalPanel = atom.workspace.addTopPanel(item: @view.getElement(), visible: false)
      else @modalPanel = atom.workspace.addTopPanel(item: @view.getElement(), visible: false)

  setupEvents: () ->
    @model.onDataChange (itemName, newItem) =>
      @ractive.set itemName, newItem
      
    @model.onDataUpdate (itemName, newItem) =>
      @ractive.merge itemName, newItem

    @view.onCancel (event) =>
      @hide()
      
    @view.onMoveUp (event) =>
      @view.selectPrev()
      
    @view.onMoveDown (event) =>
      @view.selectNext()
      
    @view.onMoveToTop (event) =>
      @view.selectFirst()
      
    @view.onMoveToBottom (event) =>
      @view.selectLast()

    @ractive.on 'search-force', (event) =>
      newSearch = @view.getSearchParams()
      @performSearch newSearch
    @ractive.on 'path-select', (event) =>
      @view.input.focus()

    @view.onConfirm (event) =>
      newSearch = @view.getSearchParams()
      sameAsPrev = @sameAsPreviousSearch newSearch
      if @view.hasSelection() and sameAsPrev
        @openResult @view.currentSelection
      else if !sameAsPrev
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
    @view.autoFill option, keyword.trim()
    return if keyword.trim() == ""
    newSearch = @view.getSearchParams()
    @performSearch newSearch

  performSearch: (newSearch) ->
    if @searchCallback?
      @view.startLoading()
      @searchCallback newSearch
      .then () =>
        @view.stopLoading()
        @view.clearSelection()
      .catch () =>
        @view.stopLoading()
        @resetSearch()
    else
      console.log "searchCallback not found."
    @previousSearch = newSearch
    @view.input.focus()

  sameAsPreviousSearch: (newSearch) ->
    return false if newSearch.keyword != @previousSearch.keyword || newSearch.option != @previousSearch.option
    return false if newSearch.path.length != @previousSearch.path.length
    for i in [0..newSearch.path.length]
      return false if newSearch.path[i] != @previousSearch.path[i]
    return true

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

  show: ->
    @prevEditor = atom.workspace.getActiveTextEditor()
    @modalPanel.show()
    @view.input.focus()

  hide: ->
    @modalPanel.hide()
    prevEditorView = atom.views.getView(@prevEditor)
    prevEditorView?.focus()

  toggle: ->
    console.log 'Atom Cscope was toggled!'
    if @modalPanel.isVisible() then @hide() else @show()

  switchPanes: ->
    if @view.input.hasFocus() and @prevEditor?
      prevEditorView = atom.views.getView(@prevEditor)
      prevEditorView?.focus()
    else
      @view.input.focus()

  togglePanelOption: (option) ->
    if parseInt @view.optionSelect.value is option
      @toggle()
    else
      @show()
      @view.autoFill(option, '')
      @model.clearResults()

  isVisible: () ->
    return @modalPanel.isVisible()

  deactivate: () ->
    @modalPanel.destroy()
    @view.destroy()