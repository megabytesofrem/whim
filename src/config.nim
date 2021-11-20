#[
  User config file for Whim. Tweak this to your hearts contents!
]#

import x11/[x, xlib, keysym]
import whim/[types, macros, wmutils]

import std/tables

proc myConfig*(wm: var Whim) =
  # Setup your keybinds here
  keybind XK_e, Mod1Mask, shell(@["echo a"])
  keybind XK_t, Mod1Mask, shell(@["echo b"])