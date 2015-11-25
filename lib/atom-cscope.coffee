AtomCscopeView = require './views/atom-cscope-view'
{CompositeDisposable} = require 'atom'
notifier = require './notifier'
cscope = require './cscope'

module.exports = AtomCscope =
  atomCscopeView: null
  modalPanel: null
  subscriptions: null
  
  setUpBindings: ->
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
        when 5 then promise = cscope.findEgrepPattern keyword, projects
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

  activate: (state) ->
    @atomCscopeView = new AtomCscopeView(state.atomCscopeViewState)
    @setUpBindings()
    
    @modalPanel = atom.workspace.addTopPanel(item: @atomCscopeView.element, visible: false)
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-cscope:toggle': => @toggle()
  
  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @atomCscopeView.destroy()

  serialize: ->
    atomCscopeViewState: @atomCscopeView.serialize()

  toggle: ->
    console.log 'AtomCscope was toggled!'

    if @modalPanel.isVisible()
      @atomCscopeView.clearItems()
      @modalPanel.hide()
    else
      @modalPanel.show()
      @atomCscopeView.inputView.findEditor.focus()
