ResultModel = require './result-model'

module.exports = 
  class ResultSetModel
    constructor: (response) ->
      @results = []
      @addResults(response)
            
    addResults: (response) ->
      if typeof response != 'undefined'
        for line in response.split("\n")
          if line != ""
            result = new ResultModel(line)
            @results.push(result)
            
    addResultSet: (resultSet) ->
      if typeof resultSet != 'undefined'
        @results = @results.concat(resultSet.results)
        
    isEmpty: ->
      if @results.length == 0
        return true
      else
        return false