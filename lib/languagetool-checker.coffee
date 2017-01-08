request = require 'request'
{CompositeDisposable, Range} = require 'atom'
CorrectionsView = require './corrections-view'

module.exports =
class LanguagetoolChecker

  constructor: (@textEditor, @languagetool) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add atom.views.getView(@textEditor), 'languagetool:suggest': => @suggest()
    @subscriptions.add atom.commands.add atom.views.getView(@textEditor), 'languagetool:clear': => @languagetool.clear()

    # @subscriptions.add @textEditor.onDidDestroy @destroy

  suggest: =>
    # suggest nothing if there is no marker at curser
    posObj = {containsBufferPosition: @textEditor.getCursorBufferPosition()}
    return unless marker = @markerLayer.findMarkers(posObj)[0]

    suggestions = @getSuggestions marker
    error = @getError marker

    @correctionsView?.destroy()
    @correctionsView = new CorrectionsView(@textEditor, error, suggestions, marker, this, @updateMisspellings)

  getError: (marker) ->
    match = @matchByMarker.get(marker)
    return match.message

  getSuggestions: (marker) ->
    match = @matchByMarker.get(marker)
    suggestions = []
    for replacement in match.replacements
      suggestions.push(replacement.value)
    return suggestions

  updateMisspellings: ->
    return

  initChecker: ->
    @markerLayer?.destroy()
    @markerLayer = @textEditor.addMarkerLayer()
    @textEditor.decorateMarkerLayer(@markerLayer, {
      type: 'highlight'
      class: 'languagetool-match'
    })
    @matchByMarker = new WeakMap
    @text = @textEditor.getText()

  destroy: ->
    @correctionsView?.destroy()
    @correctionsView = null
    @markerLayer?.destroy()
    @markerLayer = null
    @matchByMarker = null
    @textEditor = null
    @languagetool = null
    @subscriptions.dispose()

  check: ->
    @initChecker()

    requestOptions =
      "url": "https://languagetool.org/api/v2/check"
      "form":
        "text": @text
        "language": atom.config.get("languagetool.language")
        "motherTongue": atom.config.get("languagetool.motherTongue")
        "preferredVariants": atom.config.get("languagetool.preferredVariants")

    request.post requestOptions, (err, resp, content) =>
      if err
        noteMsg = "LanguageTool: connection to API failed."
        erroptions =
          "stack": err.stack
          "detail": err.message
          "dismissable": true
        atom.notifications.addError(noteMsg, erroptions)
      else if resp.statusCode isnt 200
        noteMsg = "Languagetool: API doesn't accept query."
        erroptions =
          "detail": content
          "dismissable": true
        atom.notifications.addError(noteMsg, erroptions)
      else
        contentObj = JSON.parse(content)
        @markSuggestions(contentObj.matches)

  markSuggestions: (matches) ->
    for match in matches
      #range = @offsetLengthToBufferRange(match.offset, match.length)
      textBuffer = @textEditor.getBuffer()
      startPos = textBuffer.positionForCharacterIndex(match.offset)
      endPos = textBuffer.positionForCharacterIndex(match.offset+match.length)
      range = [startPos, endPos]
      marker = @markerLayer.markBufferRange(range, {invalidate: 'touch'})
      @matchByMarker.set(marker, match)
