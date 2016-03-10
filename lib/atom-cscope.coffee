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
    cscopeSourceFiles:
      title: 'Source file extensions'
      description: 'Enter the extensions of the source files with which you want cscope generated (with spaces)'
      type: 'string'
      default: '.c .cc .cpp .h .hpp'
    cscopeBinaryLocation:
      title: 'Path for cscope binary'
      description: 'Enter the full path to cscope program'
      type: 'string'
      default: 'cscope'

  refreshCscopeDB: ->
    notifier.addInfo "Refreshing... Please wait"
    exts = atom.config.get('atom-cscope.cscopeSourceFiles')
    return if exts.trim() is ""

    cscope.setupCscope atom.project.getPaths(), exts, true
    .then (data) =>
      notifier.addSuccess "Success: Refreshed cscope database"
      @atomCscopeView.inputView.redoSearch()
    .catch (data) ->
      notifier.addError "Error: Unable to refresh cscope database"
      console.log data
    @atomCscopeView.inputView.findEditor.focus() if @atomCscopeView.isVisible()

  setUpEvents: ->
    @atomCscopeView.on 'click', 'button#refresh', => @refreshCscopeDB()

    @atomCscopeView.onSearch (params) =>
      option = params.option
      keyword = params.keyword
      path = params.projectPath

      projects = if path is -1 then atom.project.getPaths() else [atom.project.getPaths()[path]]
      
      # The option must be acceptable by cscope
      if option not in [0, 1, 2, 3, 4, 6, 7, 8, 9]
        notifier.addError "Error: Invalid option: " + option
        return

      cscope.runCscopeCommands option, keyword, projects
      .then (data) =>
        @atomCscopeView.clearItems()
        @atomCscopeView.applyResultSet(data)
      .catch (data) =>
        if data.message.indexOf("cannot open file cscope.out") > 0
          notifier.addError "Error: Please generate the cscope database."
        else
          notifier.addError "Error: " + data.message
        
    @atomCscopeView.onResultClick (result) =>
      atom.workspace.open(result.getFilePath(), {initialLine: (result.lineNumber - 1)})
  
  togglePanelOption: (option) ->
    if @atomCscopeView.inputView.getSelectedOption() is option
      @toggle()
    else
      @show()
      @atomCscopeView.inputView.autoFill(option, '')
      @atomCscopeView.listView.clearItems()

  setUpBindings: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'atom-cscope:toggle': => @toggle()
      'core:cancel': => @hide() if @modalPanel.isVisible()
      'atom-cscope:focus-next': => @switchPanes() if @modalPanel.isVisible()
      'atom-cscope:refresh-db': => @refreshCscopeDB()
      'atom-cscope:project-select': => @atomCscopeView.inputView.openProjectSelector()
      
    @subscriptions.add atom.commands.add 'atom-workspace', 
      'atom-cscope:toggle-symbol': => @togglePanelOption(0)
      'atom-cscope:toggle-global-definition': => @togglePanelOption(1)
      'atom-cscope:toggle-functions-called-by': => @togglePanelOption(2)
      'atom-cscope:toggle-functions-calling': => @togglePanelOption(3)
      'atom-cscope:toggle-text-string': => @togglePanelOption(4)
      'atom-cscope:toggle-egrep-pattern': => @togglePanelOption(6)
      'atom-cscope:toggle-file': => @togglePanelOption(7)
      'atom-cscope:toggle-files-including': => @togglePanelOption(8)
      'atom-cscope:toggle-assignments-to': => @togglePanelOption(9)

    @subscriptions.add atom.commands.add 'atom-workspace', 
      'atom-cscope:find-symbol': => @autoInputFromCursor(0)
      'atom-cscope:find-global-definition': => @autoInputFromCursor(1)
      'atom-cscope:find-functions-called-by': => @autoInputFromCursor(2)
      'atom-cscope:find-functions-calling': => @autoInputFromCursor(3)
      'atom-cscope:find-text-string': => @autoInputFromCursor(4)
      'atom-cscope:find-egrep-pattern': => @autoInputFromCursor(6)
      'atom-cscope:find-file': => @autoInputFromCursor(7)
      'atom-cscope:find-files-including': => @autoInputFromCursor(8)
      'atom-cscope:find-assignments-to': => @autoInputFromCursor(9)

  autoInputFromCursor: (option) ->
    activeEditor = atom.workspace.getActiveTextEditor()

    if not activeEditor?
      notifier.addInfo "Could not find text under cursor."
      return

    selectedText = activeEditor.getSelectedText()

    keyword = if selectedText is "" then activeEditor.getWordUnderCursor() else selectedText
    @show()
    @atomCscopeView.inputView.invokeSearch(option, keyword)
  
  attachModal: (state) ->
    @atomCscopeView = new AtomCscopeView(state.atomCscopeViewState)
    @setupModalLocation()
    atom.config.onDidChange 'atom-cscope.WidgetLocation', (event) =>
      # Just for UX sake - If the panel was already visible when the user
      # changed location in settings, we display it again
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
    prevEditorView = atom.views.getView(@prevEditor)
    prevEditorView?.focus()

  toggle: ->
    if @modalPanel.isVisible() then @hide() else @show()
    
  switchPanes: ->
    if @atomCscopeView.inputView.findEditor.hasFocus()
      prevEditorView = atom.views.getView(@prevEditor)
      prevEditorView?.focus()
    else
      @atomCscopeView.inputView.findEditor.focus()
