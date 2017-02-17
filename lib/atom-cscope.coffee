{CompositeDisposable} = require 'atom'

AtomCscopeModel = require './models/atom-cscope-model'
AtomCscopeView = require './views/atom-cscope-view'
AtomCscopeViewModel = require './viewModels/atom-cscope-view-model'

module.exports = AtomCscope =
  atomCscopeView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @model = new AtomCscopeModel
    @view = new AtomCscopeView
    @viewModel = new AtomCscopeViewModel(@view.getElement(), @model)
    @modalPanel = atom.workspace.addTopPanel(item: @viewModel.view, visible: false)

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
