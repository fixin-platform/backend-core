#!/usr/bin/env coffee

#gc = new (require "gc-stats")()
#
#statsCounter = 0
#usedHeapSizeIncrementCounter = 0
#previousUsedHeapSize = 0
#gc.on "stats", (stats) ->
#  return unless stats.gctype >= 2
#  statsCounter++
#  if stats.after.usedHeapSize > previousUsedHeapSize
#    usedHeapSizeIncrementCounter++
#  else
#    usedHeapSizeIncrementCounter--
#  previousUsedHeapSize = stats.after.usedHeapSize
#  console.log usedHeapSizeIncrementCounter
#  if usedHeapSizeIncrementCounter > 100 # "pattern detected"
#    process.exit(1)
#  if statsCounter > 1000 # "timeout"
#    process.exit(0)

#maxMeasurements = 100
#totalHeapUsed = 0
#measurementCounter = -10
#measurementInterval = 100
#setInterval ->
#  measurementCounter++
#  if measurementCounter
#    totalHeapUsed += process.memoryUsage().heapUsed
#, measurementInterval
#setTimeout ->
#  console.log "slope: ", totalHeapUsed / measurementCounter
#  process.exit(0)
#, maxMeasurements * measurementInterval

previousRss = 0
ticks = 0

withoutLeakNoop = ->
#  ticks++
#  console.log process.memoryUsage().heapUsed
#  if ticks > 100
#    if previousHeapUsed - currentHeapUsed > 1000000
#      console.log previousHeapUsed, currentHeapUsed
#    previousHeapUsed = currentHeapUsed
#  setTimeout(withoutLeakNoop)

withoutLeakPeriodicallyCleaningArray = ->
  global.array ?= []
  global.array.push new Array(10000).join("*")
  if global.array.length > 234
    global.array = []

withoutLeakLocalVar = ->
  a = new Array(100000).join("*")

withLeakArray = ->
  global.array ?= []
  global.array.push new Array(10000).join("*")
#  setTimeout(withLeakArray)

#withLeakArray()

slopes = 0
previousRss = currentRss = 0
maxMeasurements = 1000
counter = -10
increasesCounter = 0
measure = ->
  withoutLeakLocalVar()
  currentRss = process.memoryUsage().rss
  if currentRss > previousRss
    previousRss = currentRss
    increasesCounter++
    console.log increasesCounter
    if increasesCounter > 20
      console.log "leak", counter, currentRss
      process.exit(1)
  counter++
  if counter < maxMeasurements
    setTimeout(measure)
  else
    process.exit(0)

measure()

#slopes = 0
#previousRss = currentRss = 0
#previousRssDiff = 0
#maxMeasurements = 100000
#counter = -10
#measure = ->
#  withoutLeakNoop()
#  currentRss = process.memoryUsage().rss
#  if currentRss isnt previousRss
#    console.log currentRss
#  if counter > 0
##    console.log currentHeapUsed, previousHeapUsed, currentHeapUsed / previousHeapUsed
#    slopes += currentRss - previousRss / previousRssDiff
#  counter++
##  if counter % 100 is 0
##    console.log slopes / counter
#  previousRssDiff = currentRss - previousRss
#  previousRss = currentRss
#  #  console.log counter, maxMeasurements, counter < maxMeasurements
#  if counter < maxMeasurements
#    setTimeout(measure)
#  else
#    console.log "Result: ", slopes / maxMeasurements
#    console.log counter, maxMeasurements
#
#measure()

# ---


#slopes = 0
#previousHeapUsed = currentHeapUsed = 0
#maxMeasurements = 100000
#counter = 0
#measure = ->
#  gc()
#  withoutLeakNoop()
#  currentHeapUsed = process.memoryUsage().heapUsed
#  if counter > 0
##    console.log currentHeapUsed, previousHeapUsed, currentHeapUsed / previousHeapUsed
#    slopes += currentHeapUsed / previousHeapUsed
#  counter++
#  if previousHeapUsed - currentHeapUsed > 100000 or counter % 100 is 0
#    console.log slopes / counter
#  previousHeapUsed = currentHeapUsed
#
##  console.log counter, maxMeasurements, counter < maxMeasurements
#  if counter < maxMeasurements
#    setTimeout(measure)
#  else
#    console.log "Result: ", slopes / maxMeasurements
#    console.log counter, maxMeasurements
#
#gc() for a in [1..10]
#measure()

