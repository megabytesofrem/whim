##
## Whim - Hackable window manager in Nim. 
##

## Whim is hackable, configure it in this file!

# Import core components
import std/[strformat, tables, osproc]

import x11/[x, xlib, keysym]
import core/[wm, wm_types, input, wrappers]

var
  whim: WM

proc initWhim() =
  whim = initWm()

proc userConfig(wm: var WM) =
  # spawn nitrogen
  discard execCmd("nitrogen --restore &")

  defineKeybind(XKc_E, Mod1Mask, "xeyes &")
  defineKeybind(XKc_T, Mod1Mask, "xrdb ~/.Xresources && urxvt &")

when isMainModule:
  echo "Initializing WM"
  initWhim()
  whim.userConfig()

  for key, cmd in whim.bindings:
    echo &"Registering key {key} -> {cmd}"
    whim.grabKey(key.code, key.modMask.uint)

  whim.doMainLoop()