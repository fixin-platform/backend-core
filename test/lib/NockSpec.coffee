#_ = require "underscore"
#Promise = require "bluebird"
#
#
#describe "Nock", ->
#  it "should work", ->
#
#    new Promise (resolve, reject) ->
#      nock.back "test/fixtures/NockSpec/GoogleSuccess.json", (recordingDone) ->
#        Promise.bind(@)
#        .then -> request.get("https://google.com/")
#        .then @assertScopesFinished
#        .then resolve
#        .catch reject
#        .finally recordingDone
#
#  it "should throw an exception in case ", ->
#
#    new Promise (resolve, reject) ->
#      # Important: don't re-record this fixture and don't uncomment the request line: this test checks exactly that nock throws an exception in case not every request in the fixture has been utilized
#      nock.back "test/fixtures/NockSpec/GoogleFail.json", (recordingDone) ->
#        Promise.bind(@)
##        .then -> request.get("https://google.com/")
#        .then @assertScopesFinished
#        .then resolve
#        .catch reject
#        .finally recordingDone
#     .should.be.rejected;
