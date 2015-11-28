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
      title: 'Live Search toggle'
      description: 'Allow Live Search?'
      type: 'boolean'
      default: true
    LiveSearchDelay:
      title: 'Live Search delay'
      description: 'Time after typing in the search box to trigger Live Search'
      type: 'integer'
      default: 800
    WidgetLocation:
      title: 'Set Widget location'
      description: 'Where do you want the widget?'
      type: 'string'
      default: 'top'
      enum: ['top', 'bottom']

  setUpEvents: ->
    @atomCscopeView.onSearch (params) =>
      option = params.option
      keyword = params.keyword
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
    @subscriptions.add atom.commands.add 'atom-workspace',
      'atom-cscope:toggle': => @toggle()
      'core:cancel': => @hide() if @modalPanel.isVisible()
      'atom-cscope:focus-next': => @switchPanes() if @modalPanel.isVisible()
      
    @subscriptions.add atom.commands.add 'atom-workspace', 
      'atom-cscope:toggle-symbol': => 
        @atomCscopeView.inputView.setSelectedOption(0)
        @toggle()
      'atom-cscope:toggle-definition': => 
        @atomCscopeView.inputView.setSelectedOption(1)
        @toggle()
      'atom-cscope:toggle-functions-called-by': => 
        @atomCscopeView.inputView.setSelectedOption(2)
        @toggle()
      'atom-cscope:toggle-functions-calling': => 
        @atomCscopeView.inputView.setSelectedOption(3)
        @toggle()
      'atom-cscope:toggle-text-string': => 
        @atomCscopeView.inputView.setSelectedOption(4)
        @toggle()
      'atom-cscope:toggle-egrep-pattern': => 
        @atomCscopeView.inputView.setSelectedOption(6)
        @toggle()
      'atom-cscope:toggle-file': => 
        @atomCscopeView.inputView.setSelectedOption(7)
        @toggle()
      'atom-cscope:toggle-files-including': => 
        @atomCscopeView.inputView.setSelectedOption(8)
        @toggle()
      'atom-cscope:toggle-assignments-to': => 
        @atomCscopeView.inputView.setSelectedOption(9)
        @toggle()

    @subscriptions.add atom.commands.add 'atom-workspace', 
      'atom-cscope:find-this-symbol': => 
        @show()
        @autoInputFromCursor(0)
      'atom-cscope:find-this-global-definition': => 
        @show()
        @autoInputFromCursor(1)
      'atom-cscope:find-functions-called-by': => 
        @show()
        @autoInputFromCursor(2)
      'atom-cscope:find-functions-calling': => 
        @show()
        @autoInputFromCursor(3)
      'atom-cscope:find-text-string': => 
        @show()
        @autoInputFromCursor(4)
      'atom-cscope:find-egrep-pattern': => 
        @show()
        @autoInputFromCursor(6)
      'atom-cscope:find-this-file': => 
        @show()
        @autoInputFromCursor(7)
      'atom-cscope:find-files-including': => 
        @show()
        @autoInputFromCursor(8)
      'atom-cscope:find-assignments-to': => 
        @show()
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

  show: ->
    @prevEditor = atom.workspace.getActiveTextEditor()
    @modalPanel.show()
    @atomCscopeView.inputView.findEditor.focus()
    
  hide: ->
    @modalPanel.hide()
    atom.views.getView(@prevEditor).focus()

  toggle: ->
    if @modalPanel.isVisible() then @hide() else @show()
    
  switchPanes: ->
    if @atomCscopeView.inputView.findEditor.hasFocus()
      atom.views.getView(@prevEditor).focus()
    else
      @atomCscopeView.inputView.findEditor.focus()
