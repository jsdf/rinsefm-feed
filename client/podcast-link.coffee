# @cjsx react.DOM
_ = require 'underscore'
react = require 'react'

module.exports = react.createClass
  displayName: 'PodcastLink'

  getPodcastUrl: ->
    podcastBaseUrl = "#{location.origin}/podcast"
    {shows} = @props

    if shows and shows.length
      "#{podcastBaseUrl}?shows=#{shows.join(',')}"
    else
      podcastBaseUrl

  render: ->    
    <div className="podcast-url">
      <p>paste the following url into the itunes <em> file > subscribe to podcast</em> window</p>
      <div className="copy-url">{@getPodcastUrl()}</div>
    </div>
