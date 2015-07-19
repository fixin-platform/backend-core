_ = require "underscore"
Promise = require "bluebird"
Match = require "mtr-match"

class Task
  constructor: (options) ->
    _.extend @, options

module.exports = Task