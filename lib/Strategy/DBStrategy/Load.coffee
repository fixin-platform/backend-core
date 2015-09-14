Match = require "mtr-match"
DBStrategy = require "../DBStrategy"

class Load extends DBStrategy
  constructor: (input, dependencies) ->
    Match.check input, Match.ObjectIncluding
      avatarId: String
    super
    @knex = dependencies.knex
    @bookshelf = dependencies.bookshelf
    Match.check @knex, Function
    Match.check @bookshelf, Object

module.exports = Load
