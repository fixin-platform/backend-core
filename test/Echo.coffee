_ = require "underscore"

class Echo
  constructor: (options) ->
    _.extend @, options
  run: ->
    @input.pipe(@output)

module.exports = Echo