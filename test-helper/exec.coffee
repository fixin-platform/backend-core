_ = require "underscore"
Promise = require "bluebird"
dargs = require "dargs"
spawnPromise = require "./spawnPromise"

module.exports = (path, options = {}, args = [], spawnOptions = {}) ->
  _.defaults options,
    settings: "#{process.env.ROOT_DIR}/settings/test.json"
    domain: "Test"
  spawnPromise("#{process.env.ROOT_DIR}/#{path}", options, args, spawnOptions)
