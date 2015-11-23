ResultModel = require './result-model'

module.exports = 
  class ResultSetModel
    constructor: (response) ->
      @results = []
      for line in response.split("\n")
        if line != ""
          result = new ResultModel(line)
          @results.push(result)