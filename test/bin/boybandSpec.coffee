_ = require "underscore"
helpers = require "../helpers"
Promise = require "bluebird"
execFileAsync = Promise.promisify require("child_process").execFile
createLogger = require "../../helper/logger"
createSWF = require "../../helper/swf"
Registrar = require "../../lib/Actor/Registrar"
registrarOptions = require "../config/registrar.json"
dependenciesOptions = require "../config/dependencies.json"

describe "Boy band", ->
  @timeout(30000) if process.env.NOCK_BACK_MODE is "record"

  registrar = null; decider = null; worker = null;

  dependencies =
    logger: createLogger(dependenciesOptions.logger)
    swf: createSWF(dependenciesOptions.swf)

  beforeEach ->
    registrar = new Registrar(registrarOptions, dependencies)

  afterEach ->

  describe "normal operation", ->

    beforeEach (setupDone) ->
      setupDone()

    it "should sing in unison", ->
      @slow(1000)
      new Promise (resolve, reject) ->
        nock.back "test/fixtures/decider/ListenToYourHeartMultiple.json", (recordingDone) ->
          Promise.resolve()
          .then -> registrar.registerAll()
          .then -> helpers.clean(dependencies.swf)
          .then -> dependencies.swf.startWorkflowExecutionAsync(
            helpers.generateWorkflowExecutionParams("ListenToYourHeart-test-workflow-1", "h e l l o")
          )
          .then -> Promise.join(

            execFileAsync("#{process.env.ROOT_DIR}/bin/worker", [
              "--once"
              "#{process.env.ROOT_DIR}/test/Echo"
            ])
            .spread (stderr, stdout) ->
              console.log "worker", stderr, stdout
              stderr.should.be.equal("")

            execFileAsync("#{process.env.ROOT_DIR}/bin/decider", [
              "--once"
              "#{process.env.ROOT_DIR}/test/ListenToYourHeart"
            ])
            .spread (stderr, stdout) ->
              console.log "decider", stderr, stdout
              stderr.should.be.equal("")

          )
          .then resolve
          .catch reject
          .finally recordingDone

  describe "error handling", ->
