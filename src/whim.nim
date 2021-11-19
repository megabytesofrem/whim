#[
  Whim - Minimal window manager in Nim. 
  Based off of https://github.com/mackstann/tinywm.
]#

import std/[strformat, tables, osproc]

from std/strutils import join
import x11/[xlib, x, xutil]

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

  wm.root = XDefaultRootWindow(wm.dpy)

  wm.keys = initTable[KeyMapping, Command]()

  myConfig(wm)
  
  for key, command in wm.keys:
    wm.grabKey(key.code, key.modMask)

proc handleCommand(cmd: Command) =
  case cmd.name:
  of "shell": discard execCmd(cmd.args.join)
  else: discard

proc onCreateNotify(ev: XCreateWindowEvent) = 
  discard

proc onReparentNotify(ev: XReparentEvent) =
  discard

proc onConfigureRequest(ev: XConfigureRequestEvent) =
  var changes: XWindowChanges
  # Copy fields from ev to changes
  changes.x = ev.x
  changes.y = ev.y
  changes.width = ev.width
  changes.height = ev.height
  changes.borderWidth = ev.borderWidth
  changes.sibling = ev.above
  changes.stackMode = ev.detail

  # Configure the window using XConfigureWindow
  discard XConfigureWindow(wm.dpy, ev.window, cuint(ev.valueMask), changes.addr)

proc onMapRequest(ev: XMapRequestEvent) = 
  # Map the window so it is visible
  wm.frameWindow(ev.window)
  discard XMapWindow(wm.dpy, ev.window)

proc mainLoop() =
  var 
    ev: XEvent
    keymapping: KeyMapping

  discard XSelectInput(
      wm.dpy,
      wm.root,
      SubstructureRedirectMask or SubstructureNotifyMask)

  while true:
    discard XNextEvent(wm.dpy, ev.addr)

    # Get the next event from X
    echo &"got event: {debugEvent(ev)}"

    case ev.theType:
    of CreateNotify: # Window created
      onCreateNotify(ev.xcreatewindow)
    of ReparentNotify:
      onReparentNotify(ev.xreparent)

    of ConfigureRequest:
      onConfigureRequest(ev.xconfigurerequest)
    of MapRequest:
      onMapRequest(ev.xmaprequest)

    # Input events
    of KeyPress:
      keymapping = wm.makeKeyMapping(ev.xkey)
      if wm.keys.hasKey(keymapping):
        echo fmt"key was pressed {wm.keys[keymapping]}"
        handleCommand(wm.keys[keymapping])
    of ButtonPress:
      echo "button was pressed"
    else: discard

when isMainModule:
  initWhim()
  mainLoop()
