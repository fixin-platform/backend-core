_ = require "underscore"
Promise = require "bluebird"
Match = require "mtr-match"

class Task
  constructor: (options, dependencies) ->
    _.extend @, options
    _.extend @, dependencies

module.exports = Task