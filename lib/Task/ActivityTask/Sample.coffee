ActivityTask = require "../ActivityTask"
Match = require "mtr-match"

class Sample extends ActivityTask
  constructor: (input, options, streams, dependencies) ->
    super
    @knex = dependencies.knex
    @bookshelf = dependencies.bookshelf
    @mongodb = dependencies.mongodb
    Match.check @knex, Function
    Match.check @bookshelf, Object
    Match.check @mongodb, Match.Any # strange kind of woman

module.exports = Sample
