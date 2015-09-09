ActivityTask = require "../ActivityTask"
Match = require "mtr-match"

class Sample extends ActivityTask
  constructor: (input, options, dependencies) ->
    super
    @knex = dependencies.knex
    @bookshelf = dependencies.bookshelf
    Match.check @knex, Function
    Match.check @bookshelf, Object

module.exports = Sample
