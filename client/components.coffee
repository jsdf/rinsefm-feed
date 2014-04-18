# @csx React.DOM
_ = require 'underscore'
React = require 'react-shim'

module.exports =
  ShowList: React.createClass
    shows: ->
      _.map @props.shows (show, index) ->
        <div key={index} className="show">
          <label><input type="checkbox" /> {show}</label>
        </div>

    render: ->
      <form>
        {@shows()}
      </form> 

