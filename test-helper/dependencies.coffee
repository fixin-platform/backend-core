_ = require "underscore"
Promise = require "bluebird"
createKnex = require "../helper/knex"
createBookshelf = require "../helper/bookshelf"
createMongoDB = require "../helper/mongodb"
createSWF = require "../helper/swf"
createLogger = require "../helper/logger"

# Maybe we can refactor the returned object to use getters and initialize dependencies only when the getters are called?
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