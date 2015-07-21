ActivityTask = require "../ActivityTask"
Match = require "mtr-match"

class Sample extends ActivityTask
  constructor: (options, dependencies) ->
    Match.check dependencies, Match.ObjectIncluding
      mongodb: Match.Any # strange kind of woman
      bookshelf: Object
    super

module.exports = Sample
