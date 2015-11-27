ResultItemView = require '../views/result-item-view'

module.exports = 
  class ResultModel
    constructor: (response, keyword) ->
      @keyword = if typeof keyword != 'undefined' then keyword else false
      @processResultString(response)
    
    processResultString: (response) ->
      @resultString = response
      data = response.split(" ", 3)
      data.push(response.replace(data.join(" ") + " ", ""))

      @fileName = data[0]
      @functionName = data[1]
      @lineNumber = parseInt(data[2])
      
      @isJustFile = data[3].trim() == '<unknown>' 
      
      if @isJustFile
        @fileName = @fileName.replace(@keyword, '<span class="text-highlight bold">\$&</span>')
      
      if !@keyword
        @lineText = data[3]
      else
        @keyword = new RegExp(@keyword)
        @lineText = data[3].replace(/</g, '&lt;')
        @lineText = @lineText.replace(/>/g, '&gt;')
        @lineText = @lineText.replace(@keyword, '<span class="text-highlight bold">\$&</span>')

    generateView: ->
      return ResultItemView.setup(@)
      