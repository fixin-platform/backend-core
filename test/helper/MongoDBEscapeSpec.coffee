_ = require "underscore"
Promise = require "bluebird"

mongodbEscape = require "../../helper/mongodb-escape"

describe "mongodbEscape @fast", ->
  it "should work", ->
    console.log "such values"
    object =
      "field.with.a.dot": true
      selector:
        api: "Trello"
        scopes: {$all: ["*"]}
    result = mongodbEscape(object)
    object.should.not.be.equal(result)
    should.not.exist(result["field.with.a.dot"])
    should.exist(result["field__dot__with__dot__a__dot__dot"])
    should.not.exist(result.selector.scopes.$all)
    should.exist(result.selector.scopes.__dollar__all)
