_ = require "underscore"
Promise = require "bluebird"
TemporaryTable = require "./TemporaryTable"

class CollisionCheckTemporaryTable extends TemporaryTable

  insert: (externalObject) ->
    @checkIfExists externalObject
    .then (exists) ->
      if not exists
        super
      else
        console.warn "Primary key collision detected!", externalObject

  checkIfExists: (externalObject) ->
    Promise.bind(@)
    .then ->
      @transaction.raw("""
              SELECT COUNT(*) as "counter" FROM "#{@bufferTableName}"
              WHERE "#{@idFieldName}" = '#{externalObject[@idFieldName]}' AND "_avatarId" = '#{@avatarId}'
            """)
    .then (result) ->
      result.rows[0].counter isnt '0'

module.exports = CollisionCheckTemporaryTable
