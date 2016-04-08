{BufferedProcess} = require 'atom'
ResultSetModel = require './models/result-set-model'

fs = require 'fs'
path = require 'path'
os = require 'os'

module.exports = CscopeCommands =
  # Courtesy: http://stackoverflow.com/a/25462405
  findRecursively: (project, startPath, filter) ->
    output = ""

    if !fs.existsSync(startPath)
      return ""

    files = fs.readdirSync(startPath)
    for i in [0...files.length - 1] by 1
      filename = path.join(startPath, files[i])
      stat = fs.lstatSync(filename)
      if stat.isDirectory()
        output += @findRecursively(project, filename, filter)
      else if filter.test(filename)
        output += path.relative(project, filename) + "\n"

    return output

  getSourceFiles: (startPath, exts) ->
    regex = ""
    for ext,index in exts.split(/\s+/)
      if index != 0 then regex += "|"
      regex += "\\" + ext
    regex = RegExp(".*(" + regex + ")$")

    if !fs.existsSync(startPath)
      return Promise.reject "Not a valid directory: " + startPath

    output = @findRecursively startPath, startPath, regex
    return Promise.resolve output

  generateCscopeDB: (project) ->
    cscope_binary = atom.config.get('atom-cscope.cscopeBinaryLocation')
    # http://stackoverflow.com/questions/4042692/cscope-unable-to-create-inverted-index-why
    # Not sure how -q should be added in windows.
    # Cscope throws error saying that 2 files are used as input.
    cscopeArgs = if os.platform() is 'win32' then '-kRbi' else '-qkRbi'
    return @runCommand cscope_binary, [cscopeArgs, 'cscope.files'], {cwd: project}

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
        reject "Couldn't find " + command
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
