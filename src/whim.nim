#[
  Whim - Minimal window manager in Nim. 
  Based off of https://github.com/mackstann/tinywm.
]#

import std/strformat, std/tables
import x11/xlib, x11/x

# types are in types.nim to avoid recursive includes
import types, wmutils

var
  # Our window manager object
  wm = Whim()

proc initWhim() =
  # Open a connection to the display
  wm.dpy = XOpenDisplay(nil)
  if wm.dpy == nil:
    quit "failed to open display"

  wm.keys = initTable[KeyMapping, Command]()

  # Setup your keybinds here
  wm.keys[makeKeyMapping(wm.dpy, "A", Mod1Mask)] = shell(@["echo", "hi"])

  for key, command in wm.keys:
    grabKey(wm.dpy, key.code, key.modMask)
  
proc mainLoop() =
  var 
    ev: XEvent
    keysym: KeySym

  while true:
    # Get the next event from X
    discard XNextEvent(wm.dpy, ev.addr)

    if ev.theType == KeyPress:
      echo fmt"key was pressed {ev.xkey.keycode}"

      if wm.keys.hasKey(makeKeyMapping(ev.xkey)):
        echo fmt"key was pressed {wm.keys[makeKeyMapping(ev.xkey)]}"  

      #discard XRaiseWindow(wm.dpy, event.xkey.subwindow)

when isMainModule:
  initWhim()
  mainLoop()
