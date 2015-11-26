{View} = require 'space-pen'

module.exports =
class ResultItemView extends View
  @content: (result, key, option, keyword) ->
    @li class: 'result-item', 'data-key': key, =>
      @span class: 'file-name', result.fileName

      if option != 7
        @span ":"
        @span class: 'line-number bold', result.lineNumber
        @span class: 'gap'
        @span class: 'highlight function-name', result.functionName
        @span class: 'gap'
        
        if option == 6
          keyword = new RegExp(keyword)
        
        codeLine = result.lineText.replace(/</g, '&lt;')
        codeLine = codeLine.replace(/>/g, '&gt;')
        codeLine = codeLine.replace(keyword, '<span class="text-highlight bold">\$&</span>')

        @div class: 'inline-block', =>
          @raw codeLine