# @csx

React = require 'react'

ShowList = require './show-list'


window.RinseFM =
  init: (shows, container) ->
    React.renderComponent ShowList({shows}), container

