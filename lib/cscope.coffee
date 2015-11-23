{BufferedProcess} = require 'atom'
ResultSetModel = require './result-set-model'

module.exports = CscopeCommands =
  runCommand: (args, options = {}) ->
    process = new Promise (resolve, reject) =>
      output = ''
      try
        new BufferedProcess
          command: 'cscope'
          args: args
          options: options
          stdout: (data) -> output += data.toString()
          stderr: (data) -> reject data.toString()
          exit: (code) -> resolve output
      catch
        reject "Couldn't find cscope"
    return process

  findThisSymbol: (keyword, cwd) ->
    response = new Promise (resolve, reject) =>
      @runCommand ['-d', '-L0', keyword], {cwd: cwd}
      .then (data) ->
        console.log data
        resolve new ResultSetModel(data)
      .catch (data) ->
        reject {success: false}
        
    return response

  findThisGlobalDefinition: (keyword, cwd) ->
    response = new Promise (resolve, reject) =>
      @runCommand ['-d', '-L1', keyword], {cwd: cwd}
      .then (data) ->
        resolve new ResultSetModel(data)
      .catch (data) ->
        reject {success: false}
        
    return response

  findFunctionsCalledBy: (keyword, cwd) ->
    response = new Promise (resolve, reject) =>
      @runCommand ['-d', '-L2', keyword], {cwd: cwd}
      .then (data) ->
        resolve new ResultSetModel(data)
      .catch (data) ->
        reject {success: false}
        
    return response

  findFunctionsCalling: (keyword, cwd) ->
    response = new Promise (resolve, reject) =>
      @runCommand ['-d', '-L3', keyword], {cwd: cwd}
      .then (data) ->
        resolve new ResultSetModel(data)
      .catch (data) ->
        reject {success: false}
        
    return response

  findTextString: (keyword, cwd) ->
    response = new Promise (resolve, reject) =>
      @runCommand ['-d', '-L4', keyword], {cwd: cwd}
      .then (data) ->
        resolve new ResultSetModel(data)
      .catch (data) ->
        reject {success: false}
        
    return response

  findEgrepPattern: (keyword, cwd) ->
    response = new Promise (resolve, reject) =>
      @runCommand ['-d', '-L5', keyword], {cwd: cwd}
      .then (data) ->
        resolve new ResultSetModel(data)
      .catch (data) ->
        reject {success: false, message: "No can do!"}
        
    return response

  findThisFile: (keyword, cwd) ->
    response = new Promise (resolve, reject) =>
      @runCommand ['-d', '-L7', keyword], {cwd: cwd}
      .then (data) ->
        resolve new ResultSetModel(data)
      .catch (data) ->
        reject {success: false}
        
    return response

  findFilesIncluding: (keyword, cwd) ->
    response = new Promise (resolve, reject) =>
      @runCommand ['-d', '-L8', keyword], {cwd: cwd}
      .then (data) ->
        resolve new ResultSetModel(data)
      .catch (data) ->
        reject {success: false}
        
    return response

  findAssignmentsTo: (keyword, cwd) ->
    response = new Promise (resolve, reject) =>
      @runCommand ['-d', '-L9', keyword], {cwd: cwd}
      .then (data) ->
        resolve new ResultSetModel(data)
      .catch (data) ->
        reject {success: false}
        
    return response