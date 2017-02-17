fs = require 'fs'
path = require 'path'

module.exports =
class AtomCscopeView
  constructor: ->
    @element = document.createElement('div')
    @element.classList.add('atom-cscope')
    @element.innerHTML = fs.readFileSync(path.join(__dirname, './view.html'))

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element
