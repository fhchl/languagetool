# LanguageTool package for Atom

A package for spell and grammar checking with [LanguageTool](https://languagetool.org/). The content of the current buffer is checked using the [languagetool.org API](http://wiki.languagetool.org/public-http-api) only when asked to do so.

### Commands

- `LanguageTool: check` checks the current buffer
- `LanguageTool: suggest` shows suggestions if curser is on an error
- `LanguageTool: clear` clears all errors

### Difference to [linter-languagetool](https://atom.io/packages/linter-languagetool)

This package only checks text when asked to do so.  Additionally, the linter package does not provide a way to choose from multiple suggestions, as e.g. spell-check does.


### Todos

- add shortcuts for checking, suggesting and clearing
- show suggest and clear context menu only when appropriate
- function to check only highlighted text
- option for using local languagetool server
- use different colors for different errors like the languagetool.org
- show corrections when hovering over errors with mouse or cursor
- testing
