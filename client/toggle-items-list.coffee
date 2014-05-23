# @cjsx react.DOM
_ = require 'underscore'
react = require 'react'

module.exports = react.createClass
  displayName: 'ToggleItemsList'

  render: ->
    {items, itemsChecked, onItemChecked} = @props

    itemInputs = _.map items, (item, index) ->
      checked = itemsChecked[item]
      toggled = not checked

      handleChange = -> onItemChecked(item, toggled)

      <label key={index} className="toggle-item">
        <input
          type="checkbox"
          checked={checked}
          onChange={handleChange}
        />
        {item}
      </label>

    <form>
      {itemInputs}
    </form>
