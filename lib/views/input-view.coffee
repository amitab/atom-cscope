{View} = require 'space-pen'
{TextEditorView}  = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'
_ = require 'underscore-plus'
path = require 'path'

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
        @select id: "path-options", outlet: 'projectSelector', =>
          @option value: '-1', "All Projects"
          for project, index in atom.project.getPaths()
            @option value: index.toString(), path.basename(project)

        @button class: "btn icon icon-search", id: "search", "Scope It!"

  initialize: (params) ->
    @subscriptions = new CompositeDisposable
    @resetPrevSearch()

    @subscriptions.add atom.config.observe 'atom-cscope.LiveSearchDelay', (newValue) =>
      @findEditor.getModel().getBuffer().stoppedChangingDelay = newValue
    
    @on 'click', 'button#search', @searchCallback
    @on 'change', 'select#cscope-options', @searchCallback
    @on 'change', 'select#path-options', => @findEditor.focus()
    @on 'core:confirm', @findEditor, (event) => @searchCallback(event) unless @isSamePreviousSearch()
    @setupLiveSearchListener()
    
    @subscriptions.add atom.project.onDidChangePaths (projects) =>
      prevSelection = @projectSelector.val()
      @projectSelector.empty()
      @projectSelector.append new Option "All", "-1"
      
      for project, index in projects
        @projectSelector.append new Option path.basename(project), index.toString()
      @projectSelector.val prevSelection
    
  resetPrevSearch: ->
    @prevSearch = { keyword: null, option: null, projectPath: null }

  searchCallback: (event) =>
    @parentView.showLoading()
    @customSearchCallback?(@getCurrentSearch())
    @prevSearch = @getCurrentSearch()
    @parentView.removeLoading()
    event?.preventDefault?()
    false
  
  # Courtesy: http://stackoverflow.com/a/20906852
  openSelectBox: (element) ->
    event = document.createEvent 'MouseEvents'
    event.initMouseEvent 'mousedown', true, true, window
    element.dispatchEvent event
  
  openProjectSelector: ->
    dropdown = document.getElementById 'path-options'
    try
      @openSelectBox dropdown
    catch error
      console.log error
    false

  getSearchKeyword: ->
    return @findEditor.getText()
    
  getSelectedOption: ->
    return parseInt(@find('select#cscope-options').val())
    
  getSelectedProjectPath: ->
    return parseInt(@find('select#path-options').val())

  setSelectedOption: (option) ->
    @find('select#cscope-options').val(option.toString())
    
  getCurrentSearch: ->
    return { keyword: @getSearchKeyword(), option: @getSelectedOption(), projectPath: @getSelectedProjectPath() }
    
  isCurrentSearchSameAs: (search) ->
    currentSearch = @getCurrentSearch()
    return _.isEqual(search, currentSearch)
    
  isSamePreviousSearch: ->
    return @isCurrentSearchSameAs(@prevSearch)
    
  setupLiveSearchListener: () ->
    @subscriptions.add atom.config.observe 'atom-cscope.LiveSearch', (newValue) =>
      @liveSearchListener = @findEditor.getModel().onDidStopChanging @searchCallback if newValue
      @liveSearchListener?.dispose?() if not newValue

  onSearch: (callback) ->
    @customSearchCallback = callback
    
  autoFill: (option, keyword) ->
    @findEditor.setText(keyword)
    @find('select#cscope-options').val(option.toString())
    
  invokeSearch: (option, keyword) ->
    @autoFill(option, keyword)
    @searchCallback()
    
  redoSearch: ->
    @resetPrevSearch()
    @searchCallback()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()
    @subscriptions.dispose()

  getElement: ->
    @element