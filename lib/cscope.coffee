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
          stderr: (data) -> reject {success: false, message: data.toString()}
          exit: (code) -> resolve new ResultSetModel(output)
      catch
        reject "Couldn't find cscope"
    return process
    
  runCscopeCommand: (num, keyword, cwd) ->
    return @runCommand 'cscope', ['-d', '-L' + num, keyword], {cwd: cwd}

  findThisSymbol: (keyword, cwd) ->
    return @runCscopeCommand '0', keyword, cwd

  findThisGlobalDefinition: (keyword, cwd) ->
    return @runCscopeCommand '1', keyword, cwd

  findFunctionsCalledBy: (keyword, cwd) ->
    return @runCscopeCommand '2', keyword, cwd

  findFunctionsCalling: (keyword, cwd) ->
    return @runCscopeCommand '3', keyword, cwd

  findTextString: (keyword, cwd) ->
    return @runCscopeCommand '4', keyword, cwd

  findEgrepPattern: (keyword, cwd) ->
    return @runCscopeCommand '5', keyword, cwd

  findThisFile: (keyword, cwd) ->
    return @runCscopeCommand '7', keyword, cwd

  findFilesIncluding: (keyword, cwd) ->
    return @runCscopeCommand '8', keyword, cwd

  findAssignmentsTo: (keyword, cwd) ->
    return @runCscopeCommand '9', keyword, cwd