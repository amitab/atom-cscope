AtomCscopeView = require './atom-cscope-view'
{CompositeDisposable} = require 'atom'
notifier = require './notifier'
cscope = require './cscope'

module.exports = AtomCscope =
  atomCscopeView: null
  modalPanel: null
  subscriptions: null
  counter: 0

  activate: (state) ->
    @atomCscopeView = new AtomCscopeView(state.atomCscopeViewState)
    @modalPanel = atom.workspace.addTopPanel(item: @atomCscopeView.element, visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-cscope:toggle': => @toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-cscope:run': => @sampleRun()
    
  sampleRun: ->
    @atomCscopeView.clearItems()
    cscope.findThisSymbol 'ConsoleOutputTest', '/home/amitabh/src/mysql-router'
    .then (data) =>
      console.log(data)
      @atomCscopeView.applyResultSet(data)
    .catch (data) =>
      notifier.addError "Error: " + data.message
  
  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @atomCscopeView.destroy()

  serialize: ->
    atomCscopeViewState: @atomCscopeView.serialize()

  toggle: ->
    console.log 'AtomCscope was toggled!'
    @atomCscopeView.addItem 'test' + @counter
    @atomCscopeView.addItem 'test' + (@counter + 1)
    @atomCscopeView.addItem 'test' + (@counter + 2)
    @atomCscopeView.addItem 'test' + (@counter + 3)
    @atomCscopeView.addItem 'test' + (@counter + 2)
    @atomCscopeView.addItem 'test' + (@counter + 3)
    @atomCscopeView.addItem 'test' + (@counter + 2)
    @atomCscopeView.addItem 'test' + (@counter + 3)

    if @modalPanel.isVisible()
      @atomCscopeView.clearItems()
      @modalPanel.hide()
    else
      @modalPanel.show()
