module.exports = 
  class ResultModel
    constructor: (response) ->
      @processResultString(response)
    
    processResultString: (response) ->
      response = response.replace("<", "&lt;");
      response = response.replace(">", "&gt;");
      @resultString = response
      data = response.split(" ", 3)
      data.push(response.replace(data.join(" ") + " ", ""))

      @fileName = data[0]
      @functionName = data[1]
      @lineNumber = parseInt(data[2])
      @lineText = data[3]
      