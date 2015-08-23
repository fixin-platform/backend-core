#!/usr/bin/env coffee

currentRss = previousRss = process.memoryUsage().rss
noop = ->
  currentRss = process.memoryUsage().rss
  if currentRss isnt previousRss
    console.log currentRss
  previousRss = currentRss
  setTimeout(noop)

noop()
