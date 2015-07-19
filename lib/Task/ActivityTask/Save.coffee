_ = require "underscore"
ActivityTask = require "../ActivityTask"
Match = require "mtr-match"

class Save extends ActivityTask
  constructor: (options) ->
    Match.check(options, Match.ObjectIncluding
      bookshelf: Object
      avatarId: String
    )
    super
    @knex = @bookshelf.knex
    @model = @createModel()
    @serializer = @createSerializer()

  createModel: -> throw new Error("Implement me!")

module.exports = Save