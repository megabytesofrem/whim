#[
  Whim - Minimal window manager in Nim. 
  Based off of https://github.com/mackstann/tinywm.
]#

import 
  std/strformat,
  std/tables, 
  std/osproc

from std/strutils import join
import x11/xlib, x11/x

# types are in types.nim to avoid recursive includes
import whim/types, whim/wmutils
import config

var
  # Our window manager object
  wm = Whim()

proc initWhim() =
  # Open a connection to the display
  wm.dpy = XOpenDisplay(nil)
  if wm.dpy == nil:
    quit "failed to open display"

  wm.keys = initTable[KeyMapping, Command]()
  grabButton(wm.dpy, 1, None, ButtonPress or ButtonReleaseMask or PointerMotionMask)
  grabButton(wm.dpy, 3, None, ButtonPress or ButtonReleaseMask or PointerMotionMask)

  myConfig(wm)

  for key, command in wm.keys:
    grabKey(wm.dpy, key.code, key.modMask)

proc handleCommand(cmd: Command) =
  case cmd.name:
  of "shell": discard execCmd(cmd.args.join)
  else: discard
  
proc mainLoop() =
  var 
    ev: XEvent
    keymapping: KeyMapping

  while true:
    # Get the next event from X
    discard XNextEvent(wm.dpy, ev.addr)

    case ev.theType:
    of KeyPress:
      keymapping = makeKeyMapping(ev.xkey)
      if wm.keys.hasKey(keymapping):
        echo fmt"key was pressed {wm.keys[keymapping]}"
        handleCommand(wm.keys[keymapping])
    of ButtonPress:
      echo "button was pressed"
    else: discard

when isMainModule:
  initWhim()
  mainLoop()
