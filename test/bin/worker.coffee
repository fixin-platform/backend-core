#invokeMocha = (args, fn) ->
#  output = undefined
#  mocha = undefined
#  listener = undefined
#  output = ''
#  mocha = spawn('./bin/mocha', args)
#
#  listener = (data) ->
#    output += data
#    return
#
#  mocha.stdout.on 'data', listener
#  mocha.stderr.on 'data', listener
#  mocha.on 'error', fn
#  mocha.on 'close', (code) ->
#    fn null,
#      output: output.split('\n').join('\n')
#      code: code
#    return
#  return
#
#Freshdesk = require "../../../lib/Binding/Freshdesk"
#ReadUsers = require "../../../lib/Job/Read/ReadUsers"
#
#describe "ReadUsers", ->
##  job = null; binding = null;
#
#  beforeEach (setupDone) ->
#    setupDone()
#
#  it "should run `echo` service", (testDone) ->
#    testDone()