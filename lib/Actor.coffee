_ = require "underscore"
Promise = require "bluebird"
AWS = require "aws-sdk"
Match = require "mtr-match"

class Actor
  constructor: (options, config) ->
    _.extend @, options
    Match.check config,
      accessKeyId: String
      secretAccessKey: String
      region: String
    @swf = Promise.promisifyAll new AWS.SWF _.extend
      apiVersion: "2012-01-25"
    , config

module.exports = Actor