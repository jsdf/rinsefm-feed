# @csx React.DOM
_ = require 'underscore'
React = require 'react'

module.exports = React.createClass
  displayName: 'ShowList'
  getShowsChecked: (shows, previousShowsChecked = {}) ->
    _.reduce(shows, (showsChecked, show) ->
      showsChecked[show] = previousShowsChecked[show] or false
      showsChecked
    , {})

  getInitialState: ->
    showsChecked: @getShowsChecked(@props.shows)

  componentWillReceiveProps: (nextProps) ->
    if nextProps.shows
      @setState
        showsChecked: @getShowsChecked(nextProps.shows, @state.showsChecked)

  setShowChecked: (show, checked) ->
    showsCheckedUpdated = @state.showsChecked
    showsCheckedUpdated[show] = checked
    @setState showsChecked: showsCheckedUpdated

  getPodcastUrl: (shows) ->
    podcastBaseUrl = "#{location.origin}/podcast"

    if shows and shows.length
      "#{podcastBaseUrl}?shows=#{shows.join(',')}"
    else
      podcastBaseUrl

  showInputs: (shows, showsChecked) ->
     _.map shows, (show, index) =>
      currentlyChecked = showsChecked[show]

      showChange = =>
        @setShowChecked(show, !currentlyChecked)

      <label key={index} className="show">
        <input 
          type="checkbox"
          checked={showsChecked[show]} 
          onChange={showChange}
        /> {show}
      </label>

  render: ->
    {shows} = @props
    {showsChecked} = @state

    showsIncluded = _.reduce(showsChecked, (showsIncluded, showChecked, show) ->
      showsIncluded.push(show) if showChecked
      showsIncluded
    , [])

    <div>
      <div className="podcast-url">
        <p>paste the following url into the itunes <em> file > subscribe to podcast</em> window</p>
        <div className="copy-url">{@getPodcastUrl(showsIncluded)}</div>
      </div>
      <form>
        {@showInputs(shows, showsChecked)}
      </form> 
    </div>
