{View} = require 'space-pen'

module.exports =
class ResultItemView extends View
  @content: (result, key) ->
    @li class: 'result-item', 'data-key': key, =>
      @span class: 'file-name', result.fileName
      @span ":"
      @span class: 'line-number bold', result.lineNumber
      @span class: 'gap'
      @span class: 'highlight function-name', result.functionName
      @span class: 'gap'
      @span class: 'code-line', result.lineText