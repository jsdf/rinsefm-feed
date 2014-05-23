# @cjsx react.DOM

react = require 'react'

ShowList = require './show-list'

window.RinseFM =
  init: (shows, container) ->
    react.renderComponent ShowList({shows}), container
