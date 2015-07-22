module.exports = (bookshelf) ->
  createTable: ->
    bookshelf.knex.schema.createTable(@::tableName, @buildTable.bind(@))
  dropTable: ->
    bookshelf.knex.schema.dropTable(@::tableName)
  getColumns: ->
    client = bookshelf.knex.schema.client
    builder = new client.TableBuilder(client, "create", @::tableName, @buildTable.bind(@))
    builder._fn.call(builder, builder)
    compiler = new client.TableCompiler(client, builder)
    for column in compiler.grouped.columns
      new client.ColumnCompiler(client, compiler, column.builder)