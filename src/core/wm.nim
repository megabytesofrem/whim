##
## Whim - Hackable window manager in Nim. 
##

import std/[strformat, tables, osproc]
import x11/[x, xlib]

# Prevent a recursive dependency
import wm_types, wrappers
import vector, input

proc initWm*(): WM =
  var wm: WM

  wm.display = XOpenDisplay(nil)

  if wm.display.isNil:
    quit "Failed to open display"

  wm.root = XDefaultRootWindow(wm.display)
  wm.bindings = initTable[KeyMapping, string]()
  wm.clients = initTable[Window, Client]()

  return wm

##
## Frame the window and draw the window decorations eg titlebar
## 
proc frameWindow*(wm: var WM, win: Window) =
  echo "called"
  var attrs: XWindowAttributes

  const BorderWidth = 2
  const BorderColor = 0x0059ff
  const BgColor = 0xffffff

  discard XGetWindowAttributes(wm.display, win, attrs.addr)

  # Create the border/frame around the window
  # TODO: make the border color and decoration color customizable

  let frame = XCreateSimpleWindow(
      wm.display,
      wm.root,
      attrs.x, attrs.y,
      attrs.width.cuint, attrs.height.cuint,
      BorderWidth, BorderColor, BgColor)

  let decoration = XCreateSimpleWindow(
      wm.display,
      frame,
      0, 0,
      attrs.width.cuint, 20,
      BorderWidth, BorderColor, BorderColor)

  discard XSelectInput(wm.display, frame, SubstructureNotifyMask or SubstructureRedirectMask)
  discard XAddToSaveSet(wm.display, win)

  # Reparent the decoration and frame
  discard XReparentWindow(wm.display, decoration, frame, 0, 0)
  discard XReparentWindow(wm.display, win, frame, 0, 20)

  # Map everything!
  for w in [win, frame, decoration]: discard XMapWindow(wm.display, w)

  echo "Framed window!"
  wm.clients[win] = newClient(frame)

  wm.grabButton(win, 1, Mod1Mask, ButtonPress or ButtonReleaseMask or ButtonMotionMask)
  wm.grabButton(win, 3, Mod1Mask, ButtonPress or ButtonReleaseMask or ButtonMotionMask)

##
## Events
##

# We dont care about these two (for now)
proc onCreateNotify(wm: WM, e: XCreateWindowEvent) = discard
proc onReparentNotify(wm: WM, e: XReparentEvent) = discard

proc onMotionNotify(wm: WM, e: XMotionEvent) = 
  let
    client = wm.clients[e.window]
    drag = initPosition(e.x_root, e.y_root)
    delta: Vector2 = drag - wm.dragStartPos

  # Update the window position
  if (e.state and Button1Mask) == Button1Mask:
    let dest = wm.dragStartFramePos + delta
    discard XMoveWindow(wm.display, client.window, dest.x, dest.y)

proc onConfigRequest(wm: WM, e: XConfigureRequestEvent) =
  var changes: XWindowChanges

  # Copy fields from e to changes
  changes.x = e.x
  changes.y = e.y
  changes.width = e.width
  changes.height = e.height
  changes.border_width = e.border_width
  changes.sibling = e.above
  changes.stack_mode = e.detail

  discard XConfigureWindow(wm.display, e.window, e.value_mask.cuint, changes.addr) 

proc onMapRequest(wm: var WM, e: XMapRequestEvent) =
  wm.frameWindow(e.window)
  discard XMapWindow(wm.display, e.window)

proc onButtonPress(wm: var WM, e: XButtonPressedEvent) = 
  # We are starting to drag/resize

  var x: cint
  var y: cint
  var width: cuint
  var height: cuint
  var border: cuint
  var depth: cuint
  var root: Window
  var window: Window

  window = wm.clients[e.window].window
  wm.dragStartPos = initPosition(e.x_root, e.y_root)

  discard XGetGeometry(
      wm.display,
      window,
      root.addr,
      x.addr, y.addr,
      width.addr, height.addr,
      border.addr, depth.addr
  )


proc onKeyPress(wm: WM, e: XKeyEvent) =
  {.push warning[Deprecated]: off.} 
  var mapping = input.newKeyMapping(e.keycode.cuchar, e.state)
  if wm.bindings.hasKey(mapping):
    echo &"Key pressed: {wm.bindings[mapping]}"
    discard execCmd(wm.bindings[mapping])
  {.pop.}

proc doMainLoop*(wm: var WM) =
  var e: XEvent

  # Select events on the root window
  discard XSelectInput(wm.display, wm.root, SubstructureRedirectMask or SubstructureNotifyMask)

  while true:
    echo &"Got event: {$e}"
    discard XNextEvent(wm.display, e.addr)

    case e.theType:
    of CreateNotify: wm.onCreateNotify e.xcreatewindow
    of ReparentNotify: wm.onReparentNotify e.xreparent
    of MotionNotify: wm.onMotionNotify e.xmotion
    of ConfigureRequest: wm.onConfigRequest e.xconfigurerequest
    of MapRequest: wm.onMapRequest e.xmaprequest

    of KeyPress: wm.onKeyPress e.xkey
    of ButtonPress: wm.onButtonPress e.xbutton
    else: discard

