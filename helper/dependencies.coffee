_ = require "underscore"
Promise = require "bluebird"
Match = require "mtr-match"
createKnex = require "./knex"
createBookshelf = require "./bookshelf"
createMongoDB = require "./mongodb"
createSWF = require "./swf"
createLogger = require "./logger"

module.exports = (settings, handle) ->
  Match.check settings, Object
  Match.check handle, String
  settings.mongodb.url = settings.mongodb.url.replace("%database%", handle)
  dependencies = {settings: settings}
  Object.defineProperties dependencies,
    knex: get: _.memoize ->
      knex = createKnex dependencies.settings.knex
      knex.Promise.longStackTraces() if dependencies.settings.isDebug
      knex
    bookshelf: get: _.memoize -> createBookshelf dependencies.knex
    mongodb: get: _.memoize -> createMongoDB dependencies.settings.mongodb
    swf: get: _.memoize -> createSWF dependencies.settings.swf
    logger: get: _.memoize -> createLogger dependencies.settings.logger
  dependencies
