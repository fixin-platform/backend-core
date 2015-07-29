_ = require "underscore"
_.mixin require "underscore.deep"
parse = require "path-parse"
fs = require "fs"

module.exports = (file) ->
  settings = JSON.parse fs.readFileSync file, {encoding: "UTF-8"}
  splinters = parse file
  fileSpecific = "#{splinters.dir}/#{splinters.name}.specific#{splinters.ext}"
  if fs.existsSync(fileSpecific)
    settingsSpecific = JSON.parse fs.readFileSync fileSpecific, {encoding: "UTF-8"}
    settings = _.deepExtend settings, settingsSpecific
  fileLocal = "#{splinters.dir}/#{splinters.name}.local#{splinters.ext}"
  if fs.existsSync(fileLocal)
    settingsLocal = JSON.parse fs.readFileSync fileLocal, {encoding: "UTF-8"}
    settings = _.deepExtend settings, settingsLocal
  settings
