{BufferedProcess} = require 'atom'
ResultSetModel = require './models/result-set-model'
fs = require 'fs'
path = require 'path'

module.exports = CscopeCommands =
  getSourceFiles: (project, exts) ->
    args = ['.']
    for ext,index in exts.split(/\s+/)
      args.push '-o' if index > 0
      args.push '-name'
      args.push '*' + ext
      
    return @runCommand 'find', args, {cwd: project}
    
  generateCscopeDB: (project) ->
    cscope_binary = atom.config.get('atom-cscope.cscopeBinaryLocation')
    return @runCommand cscope_binary, ['-qRbi', 'cscope.files'], {cwd: project}
    
  writeToFile: (project, fileName, content) ->
    filePath = path.join(project, fileName)
    return new Promise (resolve, reject) ->
      fs.writeFile filePath, content, (err) ->
        reject {success: false, info: err.toString()} if err
        resolve {success: true}
        
  setupCscopeForPath: (project, exts, force) ->
    cscopeExists = if force then Promise.reject force else @cscopeExists project
    cscopeExists.then (data) =>
      return Promise.resolve {success: true}
    .catch (data) =>
      sourceFileGen = @getSourceFiles project, exts
      writeCscopeFiles = sourceFileGen.then (data) =>
        return @writeToFile project, 'cscope.files', data
      dbGen = writeCscopeFiles.then (data) =>
        return @generateCscopeDB project
        
      return Promise.all([sourceFileGen, writeCscopeFiles, dbGen])
      
  setupCscope: (projects, exts, force = false) ->
    promises = []
    for project in projects
      promises.push @setupCscopeForPath project, exts, force
      
    return Promise.all(promises)
    
  cscopeExists: (project) ->
    filePath = path.join(project, 'cscope.out')
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
    if keyword.trim() is ''
      return Promise.resolve new ResultSetModel()
    else
      return new Promise (resolve, reject) =>
        @runCommand cscope_binary, ['-dL' + num, keyword], {cwd: cwd}
        .then (data) ->
          resolve new ResultSetModel(keyword, data, cwd)
        .catch (data) ->
          reject data

  runCscopeCommands: (num, keyword, projects) ->
    promises = []
    resultSet = new ResultSetModel(keyword)
    for project in projects
      promises.push(@runCscopeCommand num, keyword, project)

    motherSwear = new Promise (resolve, reject) =>
      Promise.all(promises)
      .then (values) ->
        for value in values
          resultSet.addResultSet(value)
        resolve resultSet
      .catch (data) ->
        reject data

    return motherSwear