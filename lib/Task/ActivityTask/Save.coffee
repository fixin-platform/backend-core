_ = require "underscore"
ActivityTask = require "../ActivityTask"
Match = require "mtr-match"

class Save extends ActivityTask
  constructor: (options, dependencies) ->
    Match.check options, Match.ObjectIncluding
      avatarId: String
    Match.check dependencies, Match.ObjectIncluding
      bookshelf: Object
    super
    @knex = @bookshelf.knex
    @model = @createModel()
    @serializer = @createSerializer()

  createModel: -> throw new Error("Implement me!")

module.exports = Save