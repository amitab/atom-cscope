AtomCscopeView = require './views/atom-cscope-view'
{CompositeDisposable} = require 'atom'
notifier = require './notifier'
cscope = require './cscope'

module.exports = AtomCscope =
  atomCscopeView: null
  modalPanel: null
  subscriptions: null

  config:
    LiveSearch:
      type: 'boolean'
      default: true
    LiveSearchDelay:
      type: 'integer'
      default: 800
    WidgetLocation:
      type: 'string'
      default: 'top'
      enum: ['top', 'bottom']

  setUpEvents: ->
    @atomCscopeView.inputView.onSearch () =>
      option = @atomCscopeView.inputView.getSelectedOption()
      keyword = @atomCscopeView.inputView.getSearchKeyword()
      projects = atom.project.getPaths()
      
      switch option
        when 0 then promise = cscope.findThisSymbol keyword, projects
        when 1 then promise = cscope.findThisGlobalDefinition keyword, projects
        when 2 then promise = cscope.findFunctionsCalledBy keyword, projects
        when 3 then promise = cscope.findFunctionsCalling keyword, projects
        when 4 then promise = cscope.findTextString keyword, projects
        when 6 then promise = cscope.findEgrepPattern keyword, projects
        when 7 then promise = cscope.findThisFile keyword, projects
        when 8 then promise = cscope.findFilesIncluding keyword, projects
        when 9 then promise = cscope.findAssignmentsTo keyword, projects
        else 
          notifier.addError "Error: Invalid Option"
          return

      promise
      .then (data) =>
        @atomCscopeView.clearItems()
        @atomCscopeView.applyResultSet(data)
      .catch (data) =>
        notifier.addError "Error: " + data.message
        
    @atomCscopeView.onResultClick (result) =>
      atom.workspace.open(result.fileName, {initialLine: (result.lineNumber - 1)})
  
  setUpBindings: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add @atomCscopeView.element,
      'core:close': => @modalPanel.hide()
      'core:cancel': => @modalPanel.hide()

    @subscriptions.add atom.commands.add 'atom-workspace', 
      'atom-cscope:toggle': => @toggle()
      'atom-cscope:find-this-symbol': => 
        @toggle()
        @autoInputFromCursor(0)
      'atom-cscope:find-this-global-definition': => 
        @toggle()
        @autoInputFromCursor(1)
      'atom-cscope:find-functions-called-by': => 
        @toggle()
        @autoInputFromCursor(2)
      'atom-cscope:find-functions-calling': => 
        @toggle()
        @autoInputFromCursor(3)
      'atom-cscope:find-text-string': => 
        @toggle()
        @autoInputFromCursor(4)
      'atom-cscope:find-egrep-pattern': => 
        @toggle()
        @autoInputFromCursor(6)
      'atom-cscope:find-this-file': => 
        @toggle()
        @autoInputFromCursor(7)
      'atom-cscope:find-files-including': => 
        @toggle()
        @autoInputFromCursor(8)
      'atom-cscope:find-assignments-to': => 
        @toggle()
        @autoInputFromCursor(9)

  autoInputFromCursor: (option) ->
    activeEditor = atom.workspace.getActiveTextEditor()
    selectedText = activeEditor.getSelectedText()

    keyword = if selectedText == "" then activeEditor.getWordUnderCursor() else selectedText
    @atomCscopeView.inputView.invokeSearch(option, keyword)
  
  attachModal: (state) ->
    @atomCscopeView = new AtomCscopeView(state.atomCscopeViewState)
    @setupModalLocation()
    atom.config.onDidChange 'atom-cscope.WidgetLocation', (event) =>
      wasVisible = if @modalPanel.isVisible() then true else false
      @modalPanel.destroy()
      @setupModalLocation()
      @modalPanel.show() if wasVisible

  setupModalLocation: ->
    switch atom.config.get('atom-cscope.WidgetLocation')
      when 'bottom' then @modalPanel = atom.workspace.addBottomPanel(item: @atomCscopeView.element, visible: false)
      when 'top' then @modalPanel = atom.workspace.addTopPanel(item: @atomCscopeView.element, visible: false)
      else @modalPanel = atom.workspace.addTopPanel(item: @atomCscopeView.element, visible: false)
  
  activate: (state) ->
    @attachModal(state)
    @setUpBindings()
    @setUpEvents()
  
  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @atomCscopeView.destroy()

  serialize: ->
    atomCscopeViewState: @atomCscopeView.serialize()

  toggle: ->
    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
      @atomCscopeView.inputView.findEditor.focus()
