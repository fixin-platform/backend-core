_ = require "underscore"
{spawn} = require "child_process"

module.exports =
  spawn: (path, args, callback) ->
    child = spawn(path, args,
#      env: _.defaults process.env,
#        DEBUG: "pigato:*"
    )
    output = ""
    recordOutput = (data) ->
      output += data
    child.stdout.on 'data', recordOutput
    child.stderr.on 'data', recordOutput
    child.on 'error', callback
    child.on 'close', (code) ->
      console.log output
      callback null,
        output: output.split('\n').join('\n')
        code: code
    child
  spawnBroker: (args, callback) ->
    path = "#{process.env.ROOT_DIR}/bin/broker"
    @spawn(path, args, callback)
  spawnDispatcher: (args, callback) ->
    path = "#{process.env.ROOT_DIR}/bin/dispatcher"
    @spawn(path, args, callback)
  spawnWorker: (args, callback) ->
    path = "#{process.env.ROOT_DIR}/bin/worker"
    @spawn(path, args, callback)
