#[
  User config file for Whim. Tweak this to your hearts contents!
]#

import x11/xlib, x11/x
import whim/types, whim/wmutils

import std/tables

proc myConfig*(wm: var Whim) =
  # Setup your keybinds here
  wm.keys[makeKeyMapping(wm.dpy, "X", Mod1Mask)] = shell(@["xeyes"])
  wm.keys[makeKeyMapping(wm.dpy, "T", Mod1Mask)] = shell(@["thunar"])