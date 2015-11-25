{View} = require 'space-pen'
{TextEditorView}  = require 'atom-space-pen-views'

module.exports =
class InputView extends View
  @content: ->
    @div class: "atom-cscope-input", =>
      @div class: "inline-block", id: "form-container", =>
        @select id: "cscope-options", =>
          @option value: '0', "Find this C symbol"
          @option value: '1', "Find this global definition"
          @option value: '2', "Find functions called by this"
          @option value: '3', "Find functions calling this"
          @option value: '4', "Find this text string"
          @option value: '5', "Find this egrep pattern"
          @option value: '7', "Find this file"
          @option value: '8', "Find files #including this file"
          @option value: '9', "Find assignments to this symbol"
        @subview 'findEditor', new TextEditorView(mini: true, placeholderText: 'Input query here...')
        @button class: "btn icon icon-search", id: "search", "Scope It!"
    
  getSearchKeyword: ->
    return @findEditor.getText()
    
  getSelectedOption: ->
    return parseInt(@find('select#cscope-options').val())
    
  onSearch: (callback) ->
    wrapperCallback = () => 
      @parentView.toggleLoading true
      callback()
      @parentView.toggleLoading false

    @findEditor.getModel().onDidStopChanging wrapperCallback
    @on 'click', 'button#search', wrapperCallback
    @on 'change', 'select#cscope-options', wrapperCallback

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element