{View} = require 'space-pen'
InputView = require './input-view'

module.exports =
class AtomCscopeView extends View
  @content: ->
    @div class: "atom-cscope", =>
      @h1 "Atom Cscope"
      @subview 'inputView', new InputView()
      @ol id: "result-container", =>
        
  addItem: (name) ->
    @find('ol#result-container').append "<li>#{name}</li>"
    
  clearItems: ->
    @find('ol#result-container').empty()
    
  addResult: (data) ->
    console.log data.functionName
    info = ""
    info += data.fileName + ":" + data.lineNumber + " [ " + data.functionName + " ]&nbsp;&nbsp;"
    info += data.lineText
    @addItem(info) 
    
  applyResultSet: (resultSet) ->
    @resultSet = resultSet
    for result in resultSet.results
      @addResult(result)

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element