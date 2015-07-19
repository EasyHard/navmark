navmark
==
Navmark is a emacs plugin to help you navigate back and forth in emacs. It would be very helpful when you jumpping between functions and files.

Emacs provides similar functionality `pop-mark-command` and `pop-global-mark`. But seperating global mark ring and buffer-local mark ring is not convenient and is not straight-forward. And there is no way to move forward by these commands. Navmark aims to solve these problems.

Usage
==
It provides two functions
`navmark/forward` and `navmark/backward`, and advise the `push-mark` to keep track on marks. Just try it out.

Todo
==
Navmark is still very primary and there are lots of things that could be improved.

1. Behavior testto demo functionality and help development.
2. Be more configurable. navmark could be a minor mode so that it is configurable when it should be enable. And keybindings are easier to customize.
