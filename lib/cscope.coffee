ResultSetModel = require './models/result-set-model'
fs = require 'fs'
path = require 'path'
spawn = require('child_process').spawn
platform = require('os').platform()

module.exports = CscopeCommands =
  getSourceFiles: (project, extStr) ->
    exts = extStr.split(/\s+/)
    out = fs.openSync(path.join(project, 'cscope.files'), 'w')
    if platform == "win32"
      cmd = 'dir'
      args = ['/b/a/s'].concat(exts)
    else
      cmd = 'find'
      args = [].concat.apply(['.', '-name', '*' + exts.shift()], ['-o', '-name', '*' + ext] for ext in exts)
    return @runCommand cmd, args, {cwd: project, detached: true, stdio: ['ignore', out, 'pipe']}

  generateCscopeDB: (project) ->
    cscope_binary = atom.config.get('atom-cscope.cscopeBinaryLocation')
    return @runCommand cscope_binary, ['-qRbi', 'cscope.files'], {cwd: project}

  setupCscopeForPath: (project, exts, force) ->
    cscopeExists = if force then Promise.reject force else @cscopeExists project
    cscopeExists.then (data) =>
      return Promise.resolve {success: true}
    .catch (data) =>
      return @getSourceFiles(project, exts).then (data) =>
        return @generateCscopeDB project

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
      child = spawn command, args, options
      if child.stdout != null then child.stdout.on 'data', (data) =>
        output += data.toString()
      if child.stderr != null then child.stderr.on 'data', (data) =>
        reject data.toString()

      child.on 'error', (err) =>
        console.log "Debug: " + err
      child.on 'close', (code) =>
        console.log "Eeek!: " + code
        if code == -2 then reject "Unable to find cscope"
        if code != 0 then reject code else resolve output

      if args.detached then child.unref()
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
