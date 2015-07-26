var local = getLocalWallaby();
var _ = require("underscore");
_.mixin(require("underscore.deep"));

var config = _.deepExtend({
  testFramework: "mocha",
  files: [
    "helper/**/*.coffee",
    "lib/**/*.coffee",
    "test/mocha.coffee"
  ],
  tests: [
    "test/**/*Spec.coffee"
  ],
  env: {
    type: "node",
    runner: "node"
  },
  bootstrap: function (wallaby) {
    var mocha = wallaby.testFramework;
    mocha.ui("bdd");
    require.main.require("test/mocha");
    try {
      var local = require(wallaby.localProjectDir + "/wallaby.local"); // need to require again here, because bootstrap runs in another context
      local.bootstrap && local.bootstrap(wallaby)
    } catch (error) {
      if (error.code !== "MODULE_NOT_FOUND") { // unexpected!
        throw error;
      }
    }
  }
}, local);

config.env = config.env || {};
config.env.params = config.env.params || {};
config.env.params.env = config.env.params.env || "";
config.env.params.env += ";ROOT_DIR="+process.cwd();

/* Duplicate code, because wallaby.js and bootstrap() run in different contexts */
function getLocalWallaby() {
  var local = {};
  try {
    local = require("./wallaby.local");
    delete local.bootstrap; // explicitly called inside global bootstrap (defined in this file)
  } catch (error) {
    if (error.code !== "MODULE_NOT_FOUND") { // unexpected!
      throw error;
    }
  }
  return local;
}

module.exports = config;
