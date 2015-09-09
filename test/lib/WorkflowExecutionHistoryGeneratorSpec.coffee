_ = require "underscore"
Promise = require "bluebird"

WorkflowExecutionHistoryGenerator = require "../../lib/WorkflowExecutionHistoryGenerator"

describe "WorkflowExecutionHistoryGenerator", ->
  generator = new WorkflowExecutionHistoryGenerator()

  commandId = "8gRbdyxrtvxFN9bzM"

  describe "events", ->

    it "should support WorkflowExecutionStarted @fast", ->
      generator.WorkflowExecutionStarted(
        messages: [
          "h e l l o"
        ]
      ,
        executionStartToCloseTimeout: 3600000
        childPolicy: "REQUEST_CANCEL"
      ,
        eventId: 42
      ).should.be.deep.equal
        eventType: "WorkflowExecutionStarted"
        eventId: 42
        eventTimestamp: null
        workflowExecutionStartedEventAttributes:
          input: JSON.stringify
            messages: [
              "h e l l o"
            ]
          executionStartToCloseTimeout: 3600000
          childPolicy: "REQUEST_CANCEL"

  describe "decisions", ->

    it "should support CompleteWorkflowExecution @fast", ->
      generator.CompleteWorkflowExecution(
        messages: [
          "h e l l o"
        ]
      ).should.be.deep.equal
        decisionType: "CompleteWorkflowExecution"
        completeWorkflowExecutionDecisionAttributes:
          result: JSON.stringify
            messages: [
              "h e l l o"
            ]

  describe "features", ->

    it "should support event lookups @fast", ->
      generator.seed -> [
        events: [
          @WorkflowExecutionStarted
            messages: [
              "h e l l o"
            ]
        ]
        decisions: [
          @ScheduleActivityTask "FreshdeskDownloadUsers",
            avatarId: "D6vpAkoHyBXPadp4c"
            params: {}
        ]
        updates: [@commandSetIsStarted commandId, "FreshdeskDownloadUsers"]
        branches: [
          events: [@ActivityTaskCompleted "FreshdeskDownloadUsers"]
          decisions: [@CompleteWorkflowExecution {success: true}]
          updates: [@commandSetIsCompleted commandId, "FreshdeskDownloadUsers"]
        ]
      ]
      histories = generator.histories()
      histories.length.should.be.equal(2)
      histories[0].events.length.should.be.equal(1 + 2)
      histories[1].events.length.should.be.equal(1 + 2 + 1 + 2 + 1 + 2)
      histories[1].events[3].eventType.should.be.equal("DecisionTaskCompleted")
      histories[1].events[3].decisionTaskCompletedEventAttributes.executionContext.should.be.equal JSON.stringify
        updates: [
          collection: "Commands"
          selector: {_id: commandId}
          modifier: {$set: {isStarted: true}}
        ]
      histories[1].events[4].eventType.should.be.equal("ActivityTaskScheduled")
      histories[1].events[5].eventType.should.be.equal("ActivityTaskStarted")
      histories[1].events[6].eventType.should.be.equal("ActivityTaskCompleted")
      histories[1].events[5].activityTaskStartedEventAttributes.scheduledEventId.should.be.equal(5)
      histories[1].events[6].activityTaskCompletedEventAttributes.scheduledEventId.should.be.equal(5)
      histories[1].events[6].activityTaskCompletedEventAttributes.startedEventId.should.be.equal(6)

  describe "histories", ->

    it "should generate simple history @fast", ->
      generator.seed -> [
        events: [
          @WorkflowExecutionStarted
            messages: [
              "h e l l o"
            ]
        ]
        decisions: [
          @ScheduleActivityTask "FreshdeskDownloadUsers",
            avatarId: "D6vpAkoHyBXPadp4c"
            params: {}
        ]
        updates: [
          @commandSetIsStarted commandId
        ]
      ]
      histories = generator.histories()
      histories.length.should.be.equal(1)
      histories.should.be.deep.equal [
        name: "WorkflowExecutionStarted -> DecisionTaskScheduled -> DecisionTaskStarted"
        events: [
          eventType: "WorkflowExecutionStarted"
          eventId: 1
          eventTimestamp: 1420000000.123
          workflowExecutionStartedEventAttributes:
            input: JSON.stringify
              messages: [
                "h e l l o"
              ]
        ,
          eventType: "DecisionTaskScheduled"
          eventId: 2
          eventTimestamp: 1420000001.123
          decisionTaskScheduledEventAttributes: {}
        ,
          eventType: "DecisionTaskStarted"
          eventId: 3
          eventTimestamp: 1420000002.123
          decisionTaskStartedEventAttributes: {}
        ]
        decisions: [
          decisionType: "ScheduleActivityTask"
          scheduleActivityTaskDecisionAttributes:
            activityType:
              name: "FreshdeskDownloadUsers"
              version: "1.0.0"
            activityId: "FreshdeskDownloadUsers"
            input: JSON.stringify
              avatarId: "D6vpAkoHyBXPadp4c"
              params: {}
        ]
        updates: [
          collection: "Commands"
          selector: {_id: commandId}
          modifier: {$set: {isStarted: true}}
        ]
      ]

  it "should run complex history @fast", ->
    generator.seed -> [
      events: [
        @WorkflowExecutionStarted
          FreshdeskDownloadUsers:
            avatarId: "D6vpAkoHyBXPadp4c"
            params: {}
          _3DCartDownloadOrders:
            avatarId: "T7JwArn9vCJLiKXbn"
            params: {}
          BellefitGenerate_3DCartOrdersByFreshdeskUserIdCollection:
            avatarIds:
              Freshdesk: "D6vpAkoHyBXPadp4c"
              _3DCart: "T7JwArn9vCJLiKXbn"
      ]
      decisions: [
        @ScheduleActivityTask "FreshdeskDownloadUsers",
          avatarId: "D6vpAkoHyBXPadp4c"
          params: {}
      ,
        @ScheduleActivityTask "_3DCartDownloadOrders",
          avatarId: "T7JwArn9vCJLiKXbn"
          params: {}
      ]
      updates: [
        @commandSetIsStarted commandId
      ]
      branches: [
        events: [
          @ActivityTaskCompleted "FreshdeskDownloadUsers"
        ,
          @ActivityTaskCompleted "_3DCartDownloadOrders"
        ]
        decisions: [
          @ScheduleActivityTask "BellefitGenerate_3DCartOrdersByFreshdeskUserIdCollection",
            avatarIds:
              Freshdesk: "D6vpAkoHyBXPadp4c"
              _3DCart: "T7JwArn9vCJLiKXbn"
        ]
        updates: []
        branches: [
          events: [
            @ActivityTaskCompleted "BellefitGenerate_3DCartOrdersByFreshdeskUserIdCollection"
          ]
          decisions: [
            @CompleteWorkflowExecution()
          ]
          updates: [
            @commandSetIsCompleted commandId, "BellefitGenerate_3DCartOrdersByFreshdeskUserIdCollection"
          ]
        ,
          events: [@ActivityTaskCompleted "FreshdeskDownloadUsers"]
          decisions: []
          updates: []
        ,
          events: [@ActivityTaskCompleted "_3DCartDownloadOrders"]
          decisions: []
          updates: []
        ,
          events: [@ActivityTaskFailed "FreshdeskDownloadUsers"]
          decisions: [@FailWorkflowExecution()]
          updates: []
        ,
          events: [@ActivityTaskFailed "_3DCartDownloadOrders"]
          decisions: [@FailWorkflowExecution()]
          updates: []
        ]
      ]
    ]
    histories = generator.histories()
    histories.should.be.an("array")
    histories.length.should.be.an.equal(7)
    # events should be different objects with identical properties
    {}.should.not.be.equal({})
    {}.should.be.deep.equal({})
    histories[0].events[0].should.be.deep.equal(histories[1].events[0])
    histories[0].events[0].should.not.be.equal(histories[1].events[0])
