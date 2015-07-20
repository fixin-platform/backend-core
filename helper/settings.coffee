_ = require "underscore"
_.mixin require "underscore.deep"
parse = require "path-parse"
fs = require "fs"

module.exports = (file) ->
  settings = JSON.parse fs.readFileSync file, {encoding: "UTF-8"}
  splinters = parse file
  fileLocal = "#{splinters.dir}/#{splinters.name}.local#{splinters.ext}"
  if fs.existsSync(fileLocal)
    settingsLocal = JSON.parse fs.readFileSync fileLocal, {encoding: "UTF-8"}
    _.deepExtend settings, settingsLocal
  settings
