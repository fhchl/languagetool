{CompositeDisposable} = require 'atom'
LanguagetoolChecker = require './languagetool-checker'

module.exports = LanguageTool =

  subscriptions: null
  checkerByEditor: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-text-editor', 'languagetool:check': => @check()
    @checkerByEditor = new WeakMap

  deactivate: ->
    @checkerByEditor = new WeakMap
    @subscriptions.dispose()

  check: ->
    if textEditor = atom.workspace.getActiveTextEditor()
      unless checker = @checkerByEditor.get(textEditor)
        checker = new LanguagetoolChecker(textEditor, LanguageTool)
        @checkerByEditor.set(textEditor, checker)
      checker.check()

  clear: ->
    textEditor = atom.workspace.getActiveTextEditor()
    if checker = @checkerByEditor.get(textEditor)
      checker.destroy()
      @checkerByEditor.delete(textEditor)
