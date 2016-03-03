{View} = require 'space-pen'

module.exports =
class ResultItemView extends View
  @content: ->
    @li class: 'result-item',  =>
      @div class: 'inline-block', style: 'margin-right: 0px', =>
        @span class: 'project-directory'
        @span class: 'gap'
        @span class: 'file-name'
      @div class: 'inline-block', outlet: 'fileDetails', =>
        @span ":"
        @span class: 'line-number bold'
        @span class: 'gap'
        @span class: 'highlight function-name'
        @span class: 'gap'
        @div class: 'inline-block code-line', =>
      
  @setup: (result) ->
    resultItem = new @
    item = resultItem.containingView()
    item.data('result-item', result)
    item.find('.project-directory').html("[" + result.projectPath + "]")
    item.find('.file-name').html(result.htmlFileName)

    if not result.isJustFile
      item.find('.line-number').text(result.lineNumber)
      item.find('.function-name').text(result.functionName)
      item.find('.code-line').html(result.htmlLineText)
    else
      resultItem.fileDetails.remove()
      
    return resultItem
    
  getResultItem: ->
    @containingView().data('result-item')