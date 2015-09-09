_ = require "underscore"
Promise = require "bluebird"
Match = require "mtr-match"
Save = require "../Save"

class TemporaryTable extends Save
  constructor: (input, options, dependencies) ->
    _.defaults input,
      bufferTableName: "UpsertData"
      idFieldName: "_uid"
    Match.check input, Match.ObjectIncluding
      bufferTableName: String
      idFieldName: String
    super
    @temporaryModel = @createModel()
    @temporaryModel::tableName = @bufferTableName

  execute: ->
    @knex.transaction (transaction) =>
      @transaction = transaction
      Promise.bind(@)
      .then -> @init()
      .then -> @emit("ready")
      .then -> @upsert()

  init: ->
    Promise.bind(@)
#    .then ->
#      transaction.raw("""
#          DROP TABLE IF EXISTS "#{@bufferTableName}"
#        """) # in case previous job errored out
    .then ->
      @transaction.raw("""
          CREATE TEMPORARY TABLE IF NOT EXISTS "#{@bufferTableName}" (LIKE "#{@model::tableName}" INCLUDING DEFAULTS INCLUDING CONSTRAINTS INCLUDING STORAGE)
          ON COMMIT DROP
        """)

  insert: (externalObject) ->
    instance = new @temporaryModel(@serializer.toInternal(externalObject))
    instance.set("_avatarId", @avatarId)
    instance.save(null, {transacting: @transaction}).bind(@)
    .then (args...) -> @emit "insert", args...

  upsert: ->
      Promise.bind(@)
      .then ->
        @transaction.raw("""
              LOCK TABLE "#{@model::tableName}" IN EXCLUSIVE MODE
            """)
      .then ->
        @transaction.raw("""
              UPDATE "#{@model::tableName}" AS storage
              SET #{@getUpdateColumns("buffer")}
              FROM "#{@bufferTableName}" AS buffer
              WHERE storage."#{@idFieldName}" = buffer."#{@idFieldName}" AND storage."_avatarId" = buffer."_avatarId"
            """)
      .then ->
        @transaction.raw("""
              INSERT INTO "#{@model::tableName}"
              SELECT buffer.*
              FROM "#{@bufferTableName}" AS buffer
              LEFT OUTER JOIN "#{@model::tableName}" as storage ON (buffer."#{@idFieldName}" = storage."#{@idFieldName}" AND buffer."_avatarId" = storage."_avatarId")
              WHERE storage."#{@idFieldName}" IS NULL
            """)
#      .then ->
#        @transaction.raw("""
#            DROP TABLE IF EXISTS "#{@bufferTableName}"
#          """)
  
  getUpdateColumns: (tableShortcut) ->
    statements = []
    for column in @model.getColumns()
      statements.push("\"#{column.getColumnName()}\" = #{tableShortcut}.\"#{column.getColumnName()}\"")
    statements.join()
  
  getSelectColumns: (tableShortcut) ->
    statements = []
    for column in @model.getColumns()
      statements.push("#{tableShortcut}.\"#{column.getColumnName()}\"")
    statements.join()

module.exports = TemporaryTable
