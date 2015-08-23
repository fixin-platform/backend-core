#testgc = (func, stats) ->
#  times = 100
#  trials = [1..times] # 10 isn't enough, as memory usage actually decreases during first runs
#  # preallocate memory
#  #    stats.heapUsed = []
#  #    for trial, index in trials
#  #      stats.heapUsed[index] = { rss: 100000000, heapTotal: 100000000, heapUsed: 100000000 }
#  stats.heapUsed = [1..times]
#  stats.leakCounter = 0
#  global.gc()
#  Promise.reduce trials, (previousHeapUsed, trial, index) ->
#    func()
#    .then ->
#      global.gc()
#      currentHeapUsed = process.memoryUsage().heapUsed
#      stats.heapUsed[index] = currentHeapUsed
#      if currentHeapUsed > previousHeapUsed
#        stats.leakCounter++
#      currentHeapUsed
#  , process.memoryUsage().heapUsed
#  .then (previousRss) ->
#    if stats.leakCounter > trials.length / 3
#      throw new Error("Leak counter has been incremented #{stats.leakCounter} times")
#
#it "should report a leak for bad code", ->
#  new Promise (resolve, reject) =>
#    leaksink = []
#    leaker = ->
##        Promise.bind(@)
##        .then -> leaksink  .push [1..100000]
## we expect the error
#    stats = {}
#    testgc(leaker, stats)
#    .then ->
#      console.log stats
#      reject(new Error("No error was thrown"))
#    .catch -> resolve()
#
#it "shouldn't report a leak for good code", ->
#  new Promise (resolve, reject) =>
#    nonleaker = ->
#      Promise.bind(@)
#      .then -> [1..100000]
#    stats = {}
#    testgc(nonleaker, stats)
#    .then resolve
#    .catch (error) ->
#      console.log stats
#      reject(error)
#
#it "shouldn't leak memory @gc", ->
##    @timeout(10000) if process.env.NOCK_BACK_MODE is "record"
##    testgc ->
##      new Promise (resolve, reject) ->
##        nock.back "test/fixtures/FreshdeskReadUsers/normal.json", (recordingDone) ->
##          sinon.spy(task.out, "write")
##          sinon.spy(task.binding, "request")
##          task.execute()
##          .then resolve
##          .catch reject
##          .finally recordingDone
##      task = new FreshdeskReadUsers(
##        _.defaults
##          params: {}
##        , input
##      ,
##        activityId: "FreshdeskReadUsers"
##      ,
##        in: new stream.Readable({objectMode: true})
##        out: new stream.Writable({objectMode: true})
##      ,
##        dependencies
##      )
