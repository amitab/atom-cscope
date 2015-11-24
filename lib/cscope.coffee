{BufferedProcess} = require 'atom'
ResultSetModel = require './result-set-model'

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
          exit: (code) -> resolve new ResultSetModel(output)
      catch
        reject "Couldn't find cscope"
    return process
    
  runCscopeCommand: (num, keyword, cwd) ->
    return @runCommand 'cscope', ['-d', '-L' + num, keyword], {cwd: cwd}

  runCscopeCommands: (num, keyword, paths) ->
    promises = []
    resultSet = new ResultSetModel()
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
    return @runCscopeCommand commandNumber, keyword, paths

  findFunctionsCalledBy: (keyword, paths) ->
    commandNumber = '2'
    return @runCscopeCommand commandNumber, keyword, paths

  findFunctionsCalling: (keyword, paths) ->
    commandNumber = '3'
    return @runCscopeCommand commandNumber, keyword, paths

  findTextString: (keyword, paths) ->
    commandNumber = '4'
    return @runCscopeCommand commandNumber, keyword, paths

  findEgrepPattern: (keyword, paths) ->
    commandNumber = '5'
    return @runCscopeCommand commandNumber, keyword, paths

  findThisFile: (keyword, paths) ->
    commandNumber = '7'
    return @runCscopeCommand commandNumber, keyword, paths

  findFilesIncluding: (keyword, paths) ->
    commandNumber = '8'
    return @runCscopeCommand commandNumber, keyword, paths

  findAssignmentsTo: (keyword, paths) ->
    commandNumber = '9'
    return @runCscopeCommand commandNumber, keyword, paths