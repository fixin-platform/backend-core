createRedis = require('redis').createClient

module.exports = (options) ->
  createRedis(options)