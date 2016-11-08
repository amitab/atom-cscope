{$, View} = require 'space-pen'
ResultItemView = require './result-item-view'
_ = require 'underscore-plus'

module.exports =
class ListView extends View
  @content: ->
    @div class: "list-container", =>
      @ul id: "empty-container", class: "background-message centered", outlet: 'emptyList', =>
        @li "No Results"
      @ol id: "result-container", class: "hidden", outlet: 'resultList'
      
  initialize: ->
    @keyUsed = false

  setItems: (items=[]) ->
    @items = items
    if items.length is 0 then @setResultsNotAvailable() else @setResultsAvailable()
    @resultList[0].innerHTML = (item.generateHTML(index) for item, index in @items)

  clearItems: ->
    @setResultsNotAvailable()
    @resultList.empty()
    
  onConfirm: (callback) ->
    @on 'click', 'li.result-item', (e) =>
      target = $(e.target).closest('li')
      return if target.length is 0
      @keyUsed = false
      @selectItemView(target)
      callback(@items[parseInt(target[0].dataset.index)])
  
    @parentView.on 'core:confirm', (e) =>
      target = @getSelectedItemView()
      return if target.length is 0 
      return if not (@keyUsed or @parentView.inputView.isSamePreviousSearch()) 
      return if not target.hasClass('selected')
      @keyUsed = false
      callback(@items[parseInt(target[0].dataset.index)])

  setResultsNotAvailable: ->
    @resultList.addClass('hidden')
    @emptyList.removeClass('hidden')

  setResultsAvailable: ->
    @resultList.removeClass('hidden')
    @emptyList.addClass('hidden')
  
  selectFirstItemView: ->
    @selectItemView(@resultList.find('li:first'))
    @resultList.scrollToTop()
    false
  
  selectLastItemView: ->
    @selectItemView(@resultList.find('li:last'))
    @resultList.scrollToBottom()
    false
  
  selectPreviousItemView: ->
    view = @getSelectedItemView().prev()
    view = @resultList.find('li:last') unless view.length
    @selectItemView(view)

  selectNextItemView: ->
    view = @getSelectedItemView().next()
    view = @resultList.find('li:first') unless view.length
    @selectItemView(view)

  selectItemView: (view) ->
    return unless view.length
    @resultList.find('.selected').removeClass('selected')
    view.addClass('selected')
    @scrollToItemView(view)

  scrollToItemView: (view) ->
    scrollTop = @resultList.scrollTop()
    desiredTop = view.position().top + scrollTop
    desiredBottom = desiredTop + view.outerHeight()

    if desiredTop < scrollTop
      @resultList.scrollTop(desiredTop)
    else if desiredBottom > @resultList.scrollBottom()
      @resultList.scrollBottom(desiredBottom) 
      
  getSelectedItemView: ->
    @resultList.find('li.selected')
