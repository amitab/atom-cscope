{CompositeDisposable} = require 'atom'

AtomCscopeModel = require './models/atom-cscope-model'
AtomCscopeView = require './views/atom-cscope-view'
AtomCscopeViewModel = require './viewModels/atom-cscope-view-model'
cscope = require './cscope'
config = require './config'
History = require './history'

module.exports = AtomCscope =
  atomCscopeView: null
  modalPanel: null
  subscriptions: null
  config: config

  refreshCscopeDB: () ->
    exts = atom.config.get('atom-cscope.cscopeSourceFiles')
    return if exts.trim() is ""

    cscope.setupCscope atom.project.getPaths(), exts, true
      .then (data) =>
        atom.notifications.addSuccess "Refreshed cscope database!"
      .catch (data) ->
        atom.notifications.addError data

  setupEvents: () ->
    @view.onCancel (event) =>
      @hide()

    @viewModel.onSearch (params) =>
      @history.clearHistory()

      option = params.option
      keyword = params.keyword
      projects = params.path

      # The option must be acceptable by cscope
      if option not in [0, 1, 2, 3, 4, 6, 7, 8, 9]
        atom.notifications.addError "Error: Invalid option: " + option
        return

      return cscope.runCscopeCommands option, keyword, projects
      .then (data) =>
        if data.length > 1000
          atom.notifications.addWarning "Results more than 1000! Maybe you were looking for something else?"
        else
          @model.results data
      .catch (data) =>
        atom.notifications.addError data

    @viewModel.onRefresh @refreshCscopeDB
    @viewModel.onResultClick (model) =>
      @history.saveCurrent() if @history.isEmpty()
      atom.workspace.open(model.projectDir, {initialLine: model.lineNumber - 1})
      @history.saveNew
        path: model.projectDir
        pos:
          row: model.lineNumber - 1
          column: 0

  attachModal: (state) ->
    @view = new AtomCscopeView
    atom.config.observe 'atom-cscope.WidgetLocation', (event) =>
      wasVisible = if @modalPanel?.isVisible() then true else false
      @modalPanel?.destroy()
      @addPanel()
      if @modalPanel? then @show() if wasVisible

  addPanel: () ->
    switch atom.config.get('atom-cscope.WidgetLocation')
      when 'bottom' then @modalPanel = atom.workspace.addBottomPanel(item: @view.getElement(), visible: false)
      when 'top' then @modalPanel = atom.workspace.addTopPanel(item: @view.getElement(), visible: false)
      else @modalPanel = atom.workspace.addTopPanel(item: @view.getElement(), visible: false)

  activate: (state) ->
    @history = new History 10
    @model = new AtomCscopeModel
    @view = new AtomCscopeView
    @attachModal()
    @viewModel = new AtomCscopeViewModel(@view, @model)
    @setupEvents()

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace',
      'atom-cscope:toggle': => @toggle()
      'atom-cscope:focus-next': => @switchPanes() if @modalPanel.isVisible()
      'atom-cscope:refresh-db': => @refreshCscopeDB()
      'atom-cscope:project-select': => @view.openProjectSelector()
      'atom-cscope:next': => @history.openNext()
      'atom-cscope:prev': => @history.openPrev()

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
      atom.notifications.addError "Could not find text under cursor."
      return

    selectedText = activeEditor.getSelectedText()
    keyword = if selectedText is "" then activeEditor.getWordUnderCursor() else selectedText
    @show() if !@modalPanel.isVisible()
    @viewModel.invokeSearch(option, keyword)

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()

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