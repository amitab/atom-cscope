fs = require 'fs'
path = require 'path'

module.exports =
class AtomCscopeView
  constructor: ->
    @element = document.createElement('div')
    @element.classList.add('atom-cscope')
    @element.id = "atom-cscope"
    @target = "#atom-cscope"
    @template = fs.readFileSync(path.join(__dirname, './view.html'))
    
    @currentSelection = 0
    
  initilaize: () ->
    @resultList = @element.querySelector '#result-container'
    @input = @element.querySelector '#query-input'
    @optionSelect = @element.querySelector '#cscope-options'
    @pathSelect = @element.querySelector '#path-options'
    
  getSearchParams: () ->
    return {
      option: parseInt @optionSelect.value,
      path: atom.project.getPaths()[parseInt @pathSelect.value],
      keyword: @input.getModel().getText(),
    }

  selectLast: () ->
    @selectItemView @resultList.childNodes.length - 1

  selectFirst: () ->
    @selectItemView 0

  selectNext: () ->
    if @resultList.childNodes[@currentSelection].classList.contains 'selected'
      @selectItemView (@currentSelection + 1) % @resultList.childNodes.length
    else
      @selectItemView (@currentSelection) % @resultList.childNodes.length
    
  selectPrev: () ->
    newIndex = (@currentSelection - 1) % @resultList.childNodes.length
    newIndex += @resultList.childNodes.length if newIndex < 0
    @selectItemView newIndex
  
  selectItemView: (index) ->
    @resultList.childNodes[@currentSelection].classList.remove 'selected'
    @resultList.childNodes[index].classList.add 'selected'
    @currentSelection = index
    @scrollToItemView index
    
  scrollToItemView: (index) ->
    scrollTop = @resultList.scrollTop
    desiredTop = @resultList.childNodes[index].offsetTop + scrollTop
    desiredBottom = desiredTop + @resultList.childNodes[index].offsetHeight

    if desiredTop < scrollTop
      @resultList.scrollTop = desiredTop
    else if desiredBottom > scrollTop + @resultList.offsetHeight
      @resultList.scrollTop = desiredBottom
      
  getSelectedItemView: ->
    return @resultList.childNodes[@currentSelection]
    

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element
