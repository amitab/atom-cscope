{CompositeDisposable} = require 'atom'
path = require 'path'

module.exports =
class AtomCscopeModel
  constructor: () ->
    @subscriptions = new CompositeDisposable
    @dataChangeCallback = null
    @dataUpdateCallback = null
    @data =
      paths: []
      results: []

    @data.paths.push path.basename project for project in atom.project.getPaths()
    @setupEvents()
      
  setupEvents: () ->
    @subscriptions.add atom.project.onDidChangePaths (projects) =>
      paths = []
      for project, index in projects
        paths.push path.basename project
      if @dataUpdateCallback? then @dataUpdateCallback 'paths', paths else console.log 'Data Update callback not found.'

  results: (results) ->
    if @dataChangeCallback?
      @dataChangeCallback 'results', results
    else
      console.log 'dataChangeCallback not found.'

  onDataChange: (callback) ->
    @dataChangeCallback = callback
    
  onDataUpdate: (callback) ->
    @dataUpdateCallback = callback
