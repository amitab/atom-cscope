{BufferedProcess} = require 'atom'
ResultSetModel = require './models/result-set-model'
fs = require 'fs'

module.exports = CscopeCommands =
  getSourceFiles: (path, exts) ->
    args = ['.']
    for ext,index in exts.split(/\s+/)
      args.push '-o' if index > 0
      args.push '-name'
      args.push '*' + ext
      
    return @runCommand 'find', args, {cwd: path}
    
  generateCscopeDB: (path) ->
    cscope_binary = atom.config.get('atom-cscope.cscopeBinaryLocation')
    return @runCommand cscope_binary, ['-q', '-R', '-b', '-i', 'cscope.files'], {cwd: path}
    
  writeToFile: (path, fileName, content) ->
    filePath = path + '/' + fileName
    return new Promise (resolve, reject) ->
      fs.writeFile filePath, content, (err) ->
        reject {success: false, info: err.toString()} if err
        resolve {success: true}
        
  setupCscopeForPath: (path, exts, force) ->
    cscopeExists = if force then Promise.reject force else @cscopeExists path
    cscopeExists.then (data) =>
      return Promise.resolve {success: true}
    .catch (data) =>
      sourceFileGen = @getSourceFiles path, exts
      writeCscopeFiles = sourceFileGen.then (data) =>
        return @writeToFile path, 'cscope.files', data
      dbGen = writeCscopeFiles.then (data) =>
        return @generateCscopeDB path
        
      return Promise.all([sourceFileGen, writeCscopeFiles, dbGen])
      
  setupCscope: (paths, exts, force = false) ->
    promises = []
    for path in paths
      promises.push @setupCscopeForPath path, exts, force
      
    return Promise.all(promises)
    
  cscopeExists: (path) ->
    filePath = path + '/' + 'cscope.out'
    return new Promise (resolve, reject) ->
      fs.access filePath, fs.R_OK | fs.W_OK, (err) =>
        reject err if err
        resolve err
    
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
    cscope_binary = atom.config.get('atom-cscope.cscopeBinaryLocation')
    if keyword.trim() == ''
      return Promise.resolve new ResultSetModel()
    else
      return new Promise (resolve, reject) =>
        @runCommand cscope_binary, ['-d', '-L', '-' + num, keyword], {cwd: cwd}
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