ResultModel = require './result-model'

module.exports = 
  class ResultSetModel
    constructor: (keyword, response) ->
      @results = []
      @keyword = keyword
      @addResults(response)
            
    addResults: (response) ->
      return if typeof response is 'undefined'
      for line in response.split("\n")
        continue if line is ""
        result = new ResultModel(line, @keyword)
        @results.push(result)
            
    addResultSet: (resultSet) ->
      if typeof resultSet isnt 'undefined' and resultSet.keyword is @keyword
        @results = @results.concat(resultSet.results)
        
    isEmpty: ->
      return @results.length is 0