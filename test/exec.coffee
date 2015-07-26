Promise = require "bluebird"
{spawn} = require("child_process")

module.exports = (path, args, options) ->
  new Promise (resolve, reject) ->
    child = spawn("#{process.env.ROOT_DIR}/#{path}", [
      "--settings", "#{process.env.ROOT_DIR}/settings/dev.json"
      "--domain", "Dev"
    ].concat(args)
    , options)
    stdoutData = ""
    stderrData = ""
    child.stdout.pipe(process.stdout)
    child.stderr.pipe(process.stderr)
    child.stdout.on "data", (data) -> stdoutData += data
    child.stderr.on "data", (data) -> stderrData += data
    child.on "error", reject
    child.on "close", (code) -> resolve [stdoutData.split("\n").join("\n"), stderrData.split("\n").join("\n"), code]
    child