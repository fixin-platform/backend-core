_ = require "underscore"
Promise = require "bluebird"
requestAsync = Promise.promisify(require "request")

module.exports = class Binding
  constructor: (options) ->
    _.extend(@, options)
    @requestAsync = requestAsync
  request: (options) ->
    @requestAsync(options)
