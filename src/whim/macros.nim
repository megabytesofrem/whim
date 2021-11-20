#[
  Whim - Minimal floating window manager in Nim. 
  Based off of https://github.com/mackstann/tinywm.
]#

import types
import std/macros

from x11/x import KeySym
import wmutils

## Macro for defining keybindings in a friendly way
macro keybind*(keysym: KeySym, modMask: int, binding) = quote do:
  wm.keys[KeyMapping(code: XKeysymToKeycode(wm.dpy, `keysym`), modMask: `modMask`)] = `binding`