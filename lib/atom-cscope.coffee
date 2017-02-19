{CompositeDisposable} = require 'atom'

AtomCscopeModel = require './models/atom-cscope-model'
AtomCscopeView = require './views/atom-cscope-view'
AtomCscopeViewModel = require './viewModels/atom-cscope-view-model'

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

  activate: (state) ->
    @model = new AtomCscopeModel
    @view = new AtomCscopeView
    @modalPanel = atom.workspace.addTopPanel(item: @view.getElement(), visible: false)
    @viewModel = new AtomCscopeViewModel(@view, @model)
    
    @viewModel.onToggle (event) =>
      @toggle()
      
    @viewModel.onSearch (event) =>
      console.log 'SEARCH'
      
    @viewModel.onRefresh (event) =>
      console.log 'REFRESH'
      
    @viewModel.onResultClick (event) =>
      console.log 'RESULT CLICK'

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-cscope:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()

  toggle: ->
    console.log 'Atom Cscope was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
