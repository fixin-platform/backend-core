_ = require "underscore"
Promise = require "bluebird"
dargs = require "dargs"
{spawn} = require("child_process")

module.exports = (path, options, args, spawnOptions) ->
  _.defaults options,
    settings: "#{process.env.ROOT_DIR}/settings/test.json"
    domain: "Test"
  new Promise (resolve, reject) ->
    child = spawn("#{process.env.ROOT_DIR}/#{path}", dargs(options).concat(args), spawnOptions)
    stdoutData = ""
    stderrData = ""
    child.stdout.pipe(process.stdout)
    child.stderr.pipe(process.stderr)
    child.stdout.on "data", (data) -> stdoutData += data
    child.stderr.on "data", (data) -> stderrData += data
    child.on "error", reject
    child.on "close", (code) -> resolve [stdoutData.split("\n").join("\n"), stderrData.split("\n").join("\n"), code]
    child
