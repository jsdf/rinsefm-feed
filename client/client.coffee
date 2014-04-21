# @csx

request = require 'superagent'
React = require 'react-shim'

{ShowList} = require './components'

showsEl = document.getElementById 'shows'

showsEl.innerText = 'loading...'

request.get('/shows').end (res) ->
  shows = res.body

  React.renderComponent ShowList({shows}), showsEl

