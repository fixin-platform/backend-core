_ = require "underscore"
Strategy = require "../DBStrategy"
Match = require "mtr-match"

class Save extends Strategy
  constructor: (input, dependencies) ->
    Match.check input, Match.ObjectIncluding
      avatarId: String
    super
    @knex = dependencies.knex
    @bookshelf = dependencies.bookshelf
    Match.check @knex, Function
    Match.check @bookshelf, Object
    @model = @createModel()
    @serializer = @createSerializer()

  createModel: -> throw new Error("Implement me!")

module.exports = Save
