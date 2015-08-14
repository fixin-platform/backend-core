_ = require "underscore"
_.mixin require "underscore.deep"
parse = require "path-parse"
fs = require "fs"

module.exports = (file) ->
  settings = {}
  splinters = parse file
  files = [
    file
    "#{splinters.dir}/#{splinters.name}.specific#{splinters.ext}"
    "#{splinters.dir}/#{splinters.name}.local#{splinters.ext}"
    "#{process.env[if process.platform is "win32" then "USERPROFILE" else "HOME"]}/.fixin/settings/#{splinters.name}.private#{splinters.ext}"
  ]
  for file in files
    console.log file, fs.existsSync(file)
    if fs.existsSync(file)
      settings = _.deepExtend settings, JSON.parse fs.readFileSync file, {encoding: "UTF-8"}
  settings
