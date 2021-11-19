#[
  User config file for Whim. Tweak this to your hearts contents!
]#

import x11/[x, xlib]
import whim/[types, macros, wmutils]

import std/tables

proc myConfig*(wm: var Whim) =
  # Setup your keybinds here
  keybind "X", Mod1Mask, shell(@["echo a"])
  keybind "T", Mod1Mask, shell(@["echo b"])
