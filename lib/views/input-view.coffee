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
    
    @on 'click', 'button#search', @searchCallback
    @on 'change', 'select#cscope-options', @searchCallback
    @on 'core:confirm', @findEditor, (event) => @searchCallback(event) unless @isSamePreviousSearch()
    @setupLiveSearchListener()

  searchCallback: (event) =>
    @parentView.showLoading()
    @customSearchCallback(@getCurrentSearch()) if @customSearchCallback
    @prevSearch = @getCurrentSearch()
    @parentView.removeLoading()
    event.preventDefault() if event
    false

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
    
  setupLiveSearchListener: () ->
    if atom.config.get('atom-cscope.LiveSearch')
      @liveSearchListener = @findEditor.getModel().onDidStopChanging @searchCallback
    else
      @liveSearchListener = false

    atom.config.onDidChange 'atom-cscope.LiveSearch', (event) =>
      if event.newValue && !@liveSearchListener
        @liveSearchListener = @findEditor.getModel().onDidStopChanging @searchCallback
      else
        @liveSearchListener.dispose()
        @liveSearchListener = false

  onSearch: (callback) ->
    @customSearchCallback = callback
    
  autoFill: (option, keyword) ->
    @findEditor.setText(keyword)
    @find('select#cscope-options').val(option.toString())
    
  invokeSearch: (option, keyword) ->
    @autoFill(option, keyword)
    @findEditor.trigger 'core:confirm'

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element