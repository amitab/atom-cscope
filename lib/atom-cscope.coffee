{CompositeDisposable} = require 'atom'

AtomCscopeModel = require './models/atom-cscope-model'
AtomCscopeView = require './views/atom-cscope-view'
AtomCscopeViewModel = require './viewModels/atom-cscope-view-model'
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

  setupEvents: () ->
    @view.onCancel (event) =>
      @hide()

    @viewModel.onSearch (params) =>
      option = params.option
      keyword = params.keyword
      projects = params.path

      # The option must be acceptable by cscope
      if option not in [0, 1, 2, 3, 4, 6, 7, 8, 9]
        notifier.addError "Error: Invalid option: " + option
        return

      cscope.runCscopeCommands option, keyword, projects
      .then (data) =>
        @model.results data
      .catch (data) =>
        atom.notifications.addError "Error: " + data

    @viewModel.onRefresh (event) =>
      exts = atom.config.get('atom-cscope.cscopeSourceFiles')
      return if exts.trim() is ""
      
      cscope.setupCscope atom.project.getPaths(), exts, true
        .then (data) =>
          atom.notifications.addSuccess "Success: Refreshed cscope database"
        .catch (data) ->
          atom.notifications.addError "Error: " + data

    @viewModel.onResultClick (event) =>
      console.log 'RESULT CLICK'

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
    @model = new AtomCscopeModel
    @view = new AtomCscopeView
    @attachModal()
    @viewModel = new AtomCscopeViewModel(@view, @model)
    @setupEvents()

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-cscope:toggle': => @toggle()

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
