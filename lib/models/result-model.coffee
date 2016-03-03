ResultItemView = require '../views/result-item-view'

module.exports = 
  class ResultModel
    constructor: (response, keyword) ->
      @keyword = keyword?
      @processResultString(response)
    
    processResultString: (response) ->
      @resultString = response
      data = response.split(" ", 3)
      data.push(response.replace(data.join(" ") + " ", ""))

      @fileName = data[0]
      @functionName = data[1]
      @lineNumber = parseInt(data[2])
      @lineText = data[3]
      
      @isJustFile = data[3].trim() is '<unknown>' 
      regex = new RegExp(@keyword, 'g')
      
      if @isJustFile
        @htmlFileName = @fileName.replace(regex, '<span class="text-highlight bold">\$&</span>')
      
      if @keyword
        @htmlLineText = data[3].replace(/</g, '&lt;')
        @htmlLineText = @htmlLineText.replace(/>/g, '&gt;')
        @htmlLineText = @htmlLineText.replace(regex, '<span class="text-highlight bold">\$&</span>')

    generateView: ->
      return ResultItemView.setup(@)
      