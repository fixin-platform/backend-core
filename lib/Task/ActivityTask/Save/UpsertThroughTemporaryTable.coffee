_ = require "underscore"
Promise = require "bluebird"
Match = require "mtr-match"
Save = require "../Save"

class UpsertThroughTemporaryTable extends Save
  constructor: (input, options, dependencies) ->
    _.defaults input,
      bufferTableName: "UpsertData"
    Match.check input, Match.ObjectIncluding
      bufferTableName: String
    super
    @temporaryModel = @createModel()
    @temporaryModel::tableName = @bufferTableName

  execute: ->
    inserts = []
    @knex.transaction (trx) =>
      Promise.bind(@)
      .then -> @progressBarSetTotal(0)
      .then -> @init(trx)
      .then ->
        new Promise (resolve, reject) =>
          @in.on "readable", =>
            while (object = @in.read()) isnt null # result may also be false, so we can't write `while (result = @in.read())`
              inserts.push @insert(trx, object) if object
            true
          @in.on "end", -> resolve(inserts)
          @in.on "error", reject
      .all() # wait for objects to be inserted
      .then -> @save(trx)
      .then -> {count: inserts.length}

  init: (trx) ->
    Promise.bind(@)
#    .then ->
#      trx.raw("""
#          DROP TABLE IF EXISTS "#{@bufferTableName}"
#        """) # in case previous job errored out
    .then ->
      trx.raw("""
          CREATE TEMPORARY TABLE IF NOT EXISTS "#{@bufferTableName}" (LIKE "#{@model::tableName}" INCLUDING DEFAULTS INCLUDING CONSTRAINTS INCLUDING STORAGE)
          ON COMMIT DROP
        """)

  insert: (trx, externalObject) ->
    instance = new @temporaryModel(@serializer.toInternal(externalObject))
    instance.set("_avatarId", @avatarId)
    instance.save(null, {transacting: trx}).bind(@)
    .then -> @progressBarIncCurrent(1)

  save: (trx) ->
      Promise.bind(@)
      .then ->
        trx.raw("""
              LOCK TABLE "#{@model::tableName}" IN EXCLUSIVE MODE
            """)
      .then ->
        trx.raw("""
              UPDATE "#{@model::tableName}" AS storage
              SET #{@getUpdateColumns("buffer")}
              FROM "#{@bufferTableName}" AS buffer
              WHERE storage."_uid" = buffer."_uid" AND storage."_avatarId" = buffer."_avatarId"
            """)
      .then ->
        trx.raw("""
              INSERT INTO "#{@model::tableName}"
              SELECT buffer.*
              FROM "#{@bufferTableName}" AS buffer
              LEFT OUTER JOIN "#{@model::tableName}" as storage ON (buffer."_uid" = storage."_uid" AND buffer."_avatarId" = storage."_avatarId")
              WHERE storage."_uid" IS NULL
            """)
#      .then ->
#        trx.raw("""
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

module.exports = UpsertThroughTemporaryTable
