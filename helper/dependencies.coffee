_ = require "underscore"
Promise = require "bluebird"
createKnex = require "./knex"
createBookshelf = require "./bookshelf"
createMongoDB = require "./mongodb"
createSWF = require "./swf"
createLogger = require "./logger"

module.exports = (settings) ->
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