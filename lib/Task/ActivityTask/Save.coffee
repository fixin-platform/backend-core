_ = require "underscore"
Job = require "../Job"
Match = require "mtr-match"

class Save extends Job
  constructor: (options) ->
    Match.check(options, Match.ObjectIncluding
      bookshelf: Object
      avatarId: Number
    )
    super
    @knex = @bookshelf.knex
    @model = @createModel()
    @serializer = @createSerializer()

  createModel: -> throw new Error("Implement me!")

module.exports = Save