path = require "path"
yargs = require "yargs"
settingsLoader = require "./settings"
createDependencies = require "./dependencies"

module.exports = ->
  argv = yargs
  .usage('Usage: [options]')
  .options(
    "e":
      alias: "env"
      type: "string"
      description: "Environment"
      demand: true
  )
  .strict()
  .argv

  settings = settingsLoader path.resolve(process.cwd(), "settings/#{argv.env}.json")
  createDependencies(settings, "")
