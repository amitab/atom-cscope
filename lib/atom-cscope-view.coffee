{View} = require 'space-pen'
InputView = require './input-view'
notifier = require './notifier'

module.exports =
class AtomCscopeView extends View
  @content: ->
    @div class: "atom-cscope", =>
      @div class: "header", =>
        @h4 class: "inline-block", "Atom Cscope v0.1"
        @span class: 'loading loading-spinner-tiny inline-block no-show'
      @subview 'inputView', new InputView()
      @ol id: "result-container", =>
        
  addItem: (name, key) ->
    @find('ol#result-container').append "<li class='result-item' data-key='#{key}'>#{name}</li>"
    
  clearItems: ->
    @find('ol#result-container').empty()
    
  addResult: (data, key) ->
    console.log data.functionName
    info = ""
    info += data.fileName + ":" + data.lineNumber + " [ " + data.functionName + " ]&nbsp;&nbsp;"
    info += data.lineText
    @addItem(info, key) 
    
  applyResultSet: (resultSet) ->
    @resultSet = resultSet
    for result, index in resultSet.results
      @addResult(result, index)

  toggleLoading: (show) ->
    if typeof show == 'undefined'
      if @find('span.loading').hasClass('no-show')
        @showLoading()
      else
        @removeLoading()
    else if !show
      @removeLoading()
    else if show
      @showLoading()
      
  removeLoading: ->
    callback = => @find('span.loading').addClass('no-show')
    setTimeout callback, 600
  
  showLoading: ->
    callback = => @find('span.loading').removeClass('no-show')
    setTimeout callback, 100

  onResultClick: (callback) ->
    self = this
    @on 'click', 'li.result-item', () ->
      key = parseInt(@getAttribute('data-key'))
      callback(self.resultSet.results[key])

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element