{SelectListView} = require 'atom-space-pen-views'

# TODO: Show corrections with comments

module.exports =
class CorrectionsView extends SelectListView
  initialize: (@editor, @errorMessage, @corrections, @marker, @updateTarget, @updateCallback) ->
    super
    @addClass('spell-check-corrections corrections popover-list')
    @attach()

  attach: ->
    @setItems(@corrections)
    @setError(@errorMessage)
    @overlayDecoration = @editor.decorateMarker(@marker, type: 'overlay', item: this)

  attached: ->
    @storeFocusedElement()
    @focusFilterEditor()

  destroy: ->
    @cancel()
    @remove()

  confirmed: (item) ->
    @cancel()
    return unless item
    @editor.transact =>
      # Update the buffer with the correction.
      @editor.setSelectedBufferRange(@marker.getBufferRange())
      @editor.insertText(item)

  cancelled: ->
    @overlayDecoration.destroy()
    @restoreFocus()

  viewForItem: (item) ->
    element = document.createElement "li"
    element.textContent = item
    element

  getFilterKey: ->
    "label"

  selectNextItemView: ->
    super
    false

  selectPreviousItemView: ->
    super
    false

  getEmptyMessage: (itemCount) ->
    if itemCount is 0
      'No corrections'
    else
      super
