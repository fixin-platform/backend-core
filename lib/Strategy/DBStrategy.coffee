_ = require "underscore"
Strategy = require "../Strategy"
Match = require "mtr-match"

class DBStrategy extends Strategy
  constructor: (input, options, dependencies) ->
    super

module.exports = DBStrategy
