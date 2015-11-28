{View} = require 'space-pen'
{TextEditorView}  = require 'atom-space-pen-views'

module.exports =
class InputView extends View
  @content: ->
    @div class: "atom-cscope-input", =>
      @div class: "inline-block", id: "form-container", =>
        @select id: "cscope-options", =>
          @option value: '0', "Find this C symbol"
          @option value: '1', "Find this global definition"
          @option value: '2', "Find functions called by this"
          @option value: '3', "Find functions calling this"
          @option value: '4', "Find this text string"
          @option value: '6', "Find this egrep pattern"
          @option value: '7', "Find this file"
          @option value: '8', "Find files #including this file"
          @option value: '9', "Find assignments to this symbol"
        @subview 'findEditor', new TextEditorView(mini: true, placeholderText: 'Input query here...')
        @button class: "btn icon icon-search", id: "search", "Scope It!"

  initialize: (params) ->
    @prevSearch = { keyword: '', option: -1 }
    @findEditor.getModel().getBuffer().stoppedChangingDelay = atom.config.get('atom-cscope.LiveSearchDelay')
    atom.config.onDidChange 'atom-cscope.LiveSearchDelay', (event) =>
      @findEditor.getModel().getBuffer().stoppedChangingDelay = event.newValue

  getSearchKeyword: ->
    return @findEditor.getText()
    
  getSelectedOption: ->
    return parseInt(@find('select#cscope-options').val())
    
  setSelectedOption: (option) ->
    @find('select#cscope-options').val(option.toString())
    
  getCurrentSearch: ->
    return { keyword: @getSearchKeyword(), option: @getSelectedOption() }
    
  isCurrentSearchSameAs: (search) ->
    currentSearch = @getCurrentSearch()
    return currentSearch.keyword == search.keyword && currentSearch.option == search.option
    
  isSamePreviousSearch: ->
    return @isCurrentSearchSameAs(@prevSearch)
    
  setupLiveSearchListener: (callback) ->
    if atom.config.get('atom-cscope.LiveSearch')
      @liveSearchListener = @findEditor.getModel().onDidStopChanging callback
    else
      @liveSearchListener = false

    atom.config.onDidChange 'atom-cscope.LiveSearch', (event) =>
      if event.newValue && !@liveSearchListener
        @liveSearchListener = @findEditor.getModel().onDidStopChanging callback
      else
        @liveSearchListener.dispose()

  onSearch: (callback) ->
    wrapperCallback = () =>
      @parentView.showLoading()
      @prevSearch = @getCurrentSearch()
      callback(@prevSearch)
      @parentView.removeLoading()
    
    @setupLiveSearchListener wrapperCallback
    @on 'click', 'button#search', wrapperCallback
    @on 'change', 'select#cscope-options', wrapperCallback
    @on 'core:confirm', @findEditor, (e) =>
      return if @isSamePreviousSearch()
      wrapperCallback()
      e.preventDefault()
      false
    
  autoFill: (option, keyword) ->
    @findEditor.setText(keyword)
    @find('select#cscope-options').val(option.toString())
    
  invokeSearch: (option, keyword) ->
    throw new Error("No search callback set!") if !@wrapperCallback

    @autoFill(option, keyword)
    @wrapperCallback()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element