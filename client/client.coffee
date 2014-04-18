# @csx

request = require 'superagent'
React = require 'react-shim'

{ShowList} = require './components'

request.get('/shows').end (res) ->
  shows = res.body

  React.renderComponent ShowList({shows}), document.getElementById 'shows'

