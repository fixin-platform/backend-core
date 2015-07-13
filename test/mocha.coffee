process.env.ROOT_DIR ?= process.cwd()

chai = require "chai"
global.should = chai.should()
#chai.config.includeStack = true

chaiAsPromised = require "chai-as-promised"
chai.use(chaiAsPromised)

chaiThings = require "chai-things"
chai.use(chaiThings)

chaiSinon = require "sinon-chai"
chai.use(chaiSinon)

global.sinon = require("sinon")

global.nconf = require "nconf"
global.config = global.nconf.file({file: "#{process.env.ROOT_DIR}/test/config.json"}).get()

global.Promise = require "bluebird"
global.Promise.longStackTraces()
