fs = require 'fs'
path = require 'path'

module.exports =
class AtomCscopeView
  constructor: () ->
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
    pathIndex = parseInt @pathSelect.value
    if pathIndex == -1
      path = atom.project.getPaths()
    else
      path = atom.project.getPaths()[pathIndex]
    search =
      option: parseInt @optionSelect.value
      path: path
      keyword: @input.getModel().getText()

    return search
    
  onMoveUp: (callback) ->
    atom.commands.add 'atom-text-editor#query-input',
      'core:move-up': callback
  
  onMoveDown: (callback) ->
    atom.commands.add 'atom-text-editor#query-input',
      'core:move-down': callback
    
  onMoveToBottom: (callback) ->
    atom.commands.add 'atom-text-editor#query-input',
      'core:move-to-bottom': callback
    
  onMoveToTop: (callback) ->
    atom.commands.add 'atom-text-editor#query-input',
      'core:move-to-top': callback
    
  onConfirm: (callback) ->
    atom.commands.add 'atom-text-editor#query-input',
      'core:confirm': callback
  
  onToggle: (callback) ->
    atom.commands.add 'atom-text-editor#query-input',
      'core:cancel': callback

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
    @resultList.childNodes[index].scrollIntoView false
      
  getSelectedItemView: ->
    return @resultList.childNodes[@currentSelection]
    

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element
