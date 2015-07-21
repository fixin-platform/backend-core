ActivityTask = require "../ActivityTask"
Match = require "mtr-match"

class Sample extends ActivityTask
  constructor: (options, dependencies) ->
    Match.check dependencies, Match.ObjectIncluding
      mongodb: Match.Any
    super

module.exports = Sample
