{BufferedProcess} = require 'atom'
ResultSetModel = require './models/result-set-model'

module.exports = CscopeCommands =
  runCommand: (command, args, options = {}) ->
    process = new Promise (resolve, reject) =>
      output = ''
      try
        new BufferedProcess
          command: command
          args: args
          options: options
          stdout: (data) -> output += data.toString()
          stderr: (data) -> reject {success: false, message: "At " + options.cwd + ": " + data.toString()}
          exit: (code) -> resolve output
      catch
        reject "Couldn't find cscope"
    return process
    
  runCscopeCommand: (num, keyword, cwd) ->
    if keyword.trim() == ''
      return new Promise (resolve, reject) ->
        resolve new ResultSetModel()
    else
      return new Promise (resolve, reject) =>
        @runCommand 'cscope', ['-d', '-L', '-' + num, keyword], {cwd: cwd}
        .then (data) ->
          resolve new ResultSetModel(keyword, data)
        .catch (data) ->
          reject data

  runCscopeCommands: (num, keyword, paths) ->
    promises = []
    resultSet = new ResultSetModel(keyword)
    for path in paths
      promises.push(@runCscopeCommand num, keyword, path)

    motherSwear = new Promise (resolve, reject) =>
      Promise.all(promises)
      .then (values) ->
        for value in values
          resultSet.addResultSet(value)
        resolve resultSet
      .catch (data) ->
        reject data

    return motherSwear

  findThisSymbol: (keyword, paths) ->
    commandNumber = '0'
    return @runCscopeCommands commandNumber, keyword, paths

  findThisGlobalDefinition: (keyword, paths) ->
    commandNumber = '1'
    return @runCscopeCommands commandNumber, keyword, paths

  findFunctionsCalledBy: (keyword, paths) ->
    commandNumber = '2'
    return @runCscopeCommands commandNumber, keyword, paths

  findFunctionsCalling: (keyword, paths) ->
    commandNumber = '3'
    return @runCscopeCommands commandNumber, keyword, paths

  findTextString: (keyword, paths) ->
    commandNumber = '4'
    return @runCscopeCommands commandNumber, keyword, paths

  findEgrepPattern: (keyword, paths) ->
    commandNumber = '6'
    return @runCscopeCommands commandNumber, keyword, paths

  findThisFile: (keyword, paths) ->
    commandNumber = '7'
    return @runCscopeCommands commandNumber, keyword, paths

  findFilesIncluding: (keyword, paths) ->
    commandNumber = '8'
    return @runCscopeCommands commandNumber, keyword, paths

  findAssignmentsTo: (keyword, paths) ->
    commandNumber = '9'
    return @runCscopeCommands commandNumber, keyword, paths