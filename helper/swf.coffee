_ = require "underscore"
AWS = require "aws-sdk"
Match = require "mtr-match"

module.exports = (options) ->
  Match.check options,
    accessKeyId: String
    secretAccessKey: String
    region: String
  _.defaults options,
    apiVersion: "2012-01-25"
  Promise.promisifyAll new AWS.SWF(options)
