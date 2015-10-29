_ = require "underscore"
Promise = require "bluebird"
Match = require "mtr-match"
Save = require "../Save"

class Upsert extends Save
  insert: (externalObject) ->
    @knex.transaction (t) =>
      @findObject(t, externalObject)
      .then (object) =>
        instance = object or new @model()
        instance.set("_avatarId", @avatarId)
        instance.save(@serializer.toInternal(externalObject), {transacting: t})
        .then (args...) -> @emit "insert", args...

  findObject: (transaction, externalObject) ->
    Promise.bind(@)
    .then ->
      new @model({_uid: externalObject._uid, _avatarId: @avatarId}).fetch({transacting: transaction})

module.exports = Upsert
