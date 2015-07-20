createKnex = require "knex"
createBookshelf = require "bookshelf"

module.exports =
  createKnex: ->
    knex = createKnex(
      client: "pg"
      connection: "postgres://foreach:foreach@localhost/foreach_local"
      pool: {min: 1, max: 10}
    )
    knex.Promise.longStackTraces()
    knex
  createBookshelf: createBookshelf