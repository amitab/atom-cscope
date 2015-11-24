{View} = require 'space-pen'
InputView = require './input-view'

module.exports =
class AtomCscopeView extends View
  @content: ->
    @div class: "atom-cscope", =>
      @div class: "header", =>
        @h4 class: "inline-block", "Atom Cscope v0.1"
        @span class: 'loading loading-spinner-tiny inline-block no-show'
      @subview 'inputView', new InputView()
      @div class: "list-container", =>
        @ul id: "empty-container", class: "background-message centered", =>
          @li "No Results"
        @ol id: "result-container", class: "hidden", =>
        
  addItem: (name, key) ->
    @find('ol#result-container').append "<li class='result-item' data-key='#{key}'>#{name}</li>"
    
  clearItems: ->
    @find('ol#result-container').empty()
    
  addResult: (data, key) ->
    console.log data.functionName
    info = ""
    info += data.fileName + ":"
    info += "<strong>" + data.lineNumber + "</strong>"
    info += "&nbsp;&nbsp;<span class='highlight'>" + data.functionName + "</span>&nbsp;&nbsp;"
    info += "<span class='code-line'>" + data.lineText + "</span>"
    @addItem(info, key) 
    
  applyResultSet: (resultSet) ->
    if resultSet.isEmpty()
      @toggleHidden true
    else
      @toggleHidden false
      
    @resultSet = resultSet
    for result, index in resultSet.results
      @addResult(result, index)
      
  toggleHidden: (show) ->
    if typeof show == 'undefined'
      if @find('ul#empty-container').hasClass('hidden')
        @showHidden()
      else
        @removeHidden()
    else if !show
      @removeHidden()
    else if show
      @showHidden()
      
  removeHidden: ->
    @find('ul#empty-container').addClass('hidden')
    @find('ol#result-container').removeClass('hidden')
  
  showHidden: ->
    @find('ul#empty-container').removeClass('hidden')
    @find('ol#result-container').addClass('hidden')

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
    setTimeout callback, 10

  onResultClick: (callback) ->
    self = this
    @on 'click', 'li.result-item', () ->
      self.find('li.selected').removeClass('selected')
      @classList.add 'selected'
      key = parseInt(@getAttribute('data-key'))
      callback(self.resultSet.results[key])

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element