# @cjsx react.DOM
_ = require 'underscore'
react = require 'react'

PodcastLink = require './podcast-link'
ToggleItemsList = require './toggle-items-list'

module.exports = react.createClass
  displayName: 'ShowList'

  getNextShowsChecked: (shows, previousShowsChecked = {}) ->
    _.reduce(shows, (showsChecked, show) ->
      showsChecked[show] = previousShowsChecked[show] or false
      showsChecked
    , {})

  setShowChecked: (show, checked) ->
    showsCheckedUpdated = _.clone @state.showsChecked
    showsCheckedUpdated[show] = checked
    @setState showsChecked: showsCheckedUpdated

  getShowsCheckedList: ->
    _.reduce(@state.showsChecked, (showsIncluded, showChecked, show) ->
      showsIncluded.push(show) if showChecked
      showsIncluded
    , [])

  getInitialState: ->
    showsChecked: @getNextShowsChecked(@props.shows)

  componentWillReceiveProps: (nextProps) ->
    if nextProps.shows
      @setState
        showsChecked: @getNextShowsChecked(nextProps.shows, @state.showsChecked)

  render: ->
    <div>
      <PodcastLink shows={@getShowsCheckedList()} />
      <ToggleItemsList 
        items={@props.shows}
        itemsChecked={@state.showsChecked}
        onItemChecked={@setShowChecked}
      />
    </div>
