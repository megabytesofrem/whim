#[
  Whim - Minimal floating window manager in Nim. 
  Based off of https://github.com/mackstann/tinywm.
]#

import types
import std/macros

import wmutils
import x11/x, x11/xlib 

proc makeKeyMapping*(wm: Whim, keystr: cstring, modMask: int): KeyMapping =
  var key = wm.convertKey(keystr)
  KeyMapping(code: key, modMask: modMask)

## Macro for defining keybindings in a friendly way
macro keybind*(keystr: string, modMask: int, binding) = quote do:
  wm.keys[KeyMapping(code: wm.convertKey(`keystr`), modMask: `modMask`)] = `binding`