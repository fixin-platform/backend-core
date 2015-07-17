_ = require "underscore"
Promise = require "bluebird"
AWS = require "aws-sdk"
Match = require "mtr-match"

class Registrar
  constructor: (options, config) ->
    _.extend @, options
    Match.check config,
      accessKeyId: String
      secretAccessKey: String
      region: String
    @swf = Promise.promisifyAll new AWS.SWF _.defaults config,
      apiVersion: "2012-01-25"
  register: ->
    Promise.bind(@)
    .then @registerDomains
  registerDomains: ->
    Promise.all(@swf.registerDomainAsync(domain) for domain in @domains)


module.exports = Registrar