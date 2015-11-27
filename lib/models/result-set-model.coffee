ResultModel = require './result-model'

module.exports = 
  class ResultSetModel
    constructor: (keyword, response) ->
      @results = []
      @keyword = keyword
      @addResults(response)
            
    addResults: (response) ->
      if typeof response != 'undefined'
        for line in response.split("\n")
          if line != ""
            result = new ResultModel(line, @keyword)
            @results.push(result)
            
    addResultSet: (resultSet) ->
      if typeof resultSet != 'undefined' && resultSet.keyword == @keyword
        @results = @results.concat(resultSet.results)
        
    isEmpty: ->
      return @results.length == 0