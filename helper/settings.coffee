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
    "~/.fixin/settings/#{splinters.name}.private#{splinters.ext}"
  ]
  for file in files
    if fs.existsSync(file)
      settings = _.deepExtend settings, JSON.parse fs.readFileSync file, {encoding: "UTF-8"}
  settings
