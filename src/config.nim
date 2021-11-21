#[
  User config file for Whim. Tweak this to your hearts contents!
]#

import x11/[x, xlib, keysym]
import whim/[types, macros, wmutils]

import std/tables

proc myConfig*(wm: var Whim) =
  # Setup your keybinds here
  keybind XK_e, Mod1Mask, shell(@["xeyes &"])
  keybind XK_c, Mod1Mask, shell(@["galculator &"])
  keybind XK_Return, Mod1Mask, shell(@["urxvt &"])