{CompositeDisposable} = require 'atom'

{AtomCscopeModel} = require '../dist/models/atom-cscope-model'
{AtomCscopeView} = require '../dist/views/atom-cscope-view'
{AtomCscopeViewModel} = require '../dist/viewModels/atom-cscope-view-model'
cscope = require './cscope'
config = require './config'
History = require './history'

module.exports = AtomCscope =
  viewModel: null
  history: null
  subscriptions: null
  config: config

  refreshCscopeDB: () ->
    exts = atom.config.get('atom-cscope.cscopeSourceFiles')
    return if exts.trim() is ""

    cscope.setupCscope atom.project.getPaths(), exts, true
      .then (data) =>
        atom.notifications.addSuccess "Refreshed cscope database!"
      .catch (data) ->
        message = if data? then data.toString() else "Unknown Error occured"
        atom.notifications.addError message

  setupEvents: () ->
    @viewModel.onSearch (params) =>
      @history?.clearHistory()

      option = params.option
      keyword = params.keyword
      projects = params.path
      if keyword.trim() == ""
        return Promise.resolve()

      # The option must be acceptable by cscope
      if option not in [0, 1, 2, 3, 4, 6, 7, 8, 9]
        atom.notifications.addError "Invalid option: " + option
        return

      return cscope.runCscopeCommands option, keyword, projects
      .catch (data) =>
        message = if data? then data.toString() else "Unknown Error occured"
        atom.notifications.addError message
        Promise.reject()
      .then (data) =>
        if data.length > @maxResults or @maxResults <= 0
          atom.notifications.addWarning "Results more than #{@maxResults}!"
          Promise.reject()
        else
          Promise.resolve(data)

    @viewModel.onRefresh @refreshCscopeDB
    @viewModel.onResultClick (model) =>
      @history?.saveCurrent() if @history?.isEmpty()
      atom.workspace.open(model.projectDir, {initialLine: model.lineNumber - 1})
      @history?.saveNew
        path: model.projectDir
        pos:
          row: model.lineNumber - 1
          column: 0

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.config.observe 'atom-cscope.EnableHistory', (newValue) =>
      if newValue
        atom.notifications.addInfo "Enabled Cscope history!"
        @history = new History 10
      else
        atom.notifications.addInfo "Disabled Cscope history!"
        @history = null

    @viewModel = new AtomCscopeViewModel @subscriptions
    @setupEvents()

    @subscriptions.add atom.commands.add 'atom-workspace',
      'atom-cscope:toggle': => @viewModel.toggle()
      'atom-cscope:switch-panes': => @viewModel.switchPanes() if @viewModel.isVisible()
      'atom-cscope:refresh-db': => @refreshCscopeDB()
      'atom-cscope:project-select': => @viewModel.view.openProjectSelector()
      'atom-cscope:next': => @history?.openNext()
      'atom-cscope:prev': => @history?.openPrev()

    @subscriptions.add atom.commands.add 'atom-workspace',
      'atom-cscope:toggle-symbol': => @viewModel.togglePanelOption(0)
      'atom-cscope:toggle-global-definition': => @viewModel.togglePanelOption(1)
      'atom-cscope:toggle-functions-called-by': => @viewModel.togglePanelOption(2)
      'atom-cscope:toggle-functions-calling': => @viewModel.togglePanelOption(3)
      'atom-cscope:toggle-text-string': => @viewModel.togglePanelOption(4)
      'atom-cscope:toggle-egrep-pattern': => @viewModel.togglePanelOption(6)
      'atom-cscope:toggle-file': => @viewModel.togglePanelOption(7)
      'atom-cscope:toggle-files-including': => @viewModel.togglePanelOption(8)
      'atom-cscope:toggle-assignments-to': => @viewModel.togglePanelOption(9)

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

    @subscriptions.add atom.config.observe 'atom-cscope.MaxCscopeResults', (newValue) =>
      @maxResults = newValue

  autoInputFromCursor: (option) ->
    activeEditor = atom.workspace.getActiveTextEditor()

    if not activeEditor?
      atom.notifications.addError "Could not find text under cursor."
      return

    selectedText = activeEditor.getSelectedText()
    keyword = if selectedText is "" then activeEditor.getWordUnderCursor() else selectedText
    if keyword.trim() == ""
      atom.notifications.addError "Could not find text under cursor."
      return
    @viewModel.show() if !@viewModel.isVisible()
    @viewModel.invokeSearch(option, keyword)

  deactivate: ->
    @viewModel.deactivate()
    @subscriptions.dispose()
