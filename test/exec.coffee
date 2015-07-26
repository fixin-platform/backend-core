Promise = require "bluebird"

execFileAsync = Promise.promisify require("child_process").execFile

module.exports = (path, args) ->
  execFileAsync("#{process.env.ROOT_DIR}/#{path}", [
    "--settings", "#{process.env.ROOT_DIR}/settings/dev.json"
    "--domain", "Dev"
  ].concat(args))