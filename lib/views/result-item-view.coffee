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
          match = keyword.exec(result.lineText)
          if match != null && match.length == 1
            highlight = match[0]
          else
            highlight = ""
        else
          highlight = keyword
  
        codeLine = result.lineText.split(keyword)
        
        if codeLine[0] == ""
          @div class: 'inline-block', =>
            @span class: 'text-highlight bold', highlight
            @span codeLine[1]
        else if codeLine[codeLine.length - 1] == ""
          @div class: 'inline-block', =>
            @span codeLine[0]
            @span class: 'text-highlight bold', highlight
        else if codeLine.length == 2
          @div class: 'inline-block', =>
            @span codeLine[0]
            @span class: 'text-highlight bold', highlight
            @span codeLine[1]
        else
          @span result.lineText