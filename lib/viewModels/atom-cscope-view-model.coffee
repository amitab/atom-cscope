{allowUnsafeNewFunction} = require 'loophole'
Vue = require 'vue'

module.exports =
class AtomCscopeViewModel
  constructor: (@view, @model) ->
    window.x = @model
    @vue = allowUnsafeNewFunction =>
      new Vue
        el: @view
        data: @model
