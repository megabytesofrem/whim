#[
  Whim - Minimal floating window manager in Nim. 
  Based off of https://github.com/mackstann/tinywm.
]#

import types
import std/[strformat, macros]

import x11/x, x11/xlib 

## Helpful for debugging
proc debugEvent*(ev: XEvent): string {.noSideEffect.} =
  case ev.theType:
  of KeyPress:  return "KeyPress"
  of KeyRelease: return "KeyRelease"
  of ButtonPress: return "ButtonPress"
  of ButtonRelease: return "ButtonRelease"
  of MotionNotify: return "MotionNotify"
  of CreateNotify: return "CreateNotify"
  of DestroyNotify: return "DestroyNotify"
  else: return &"Unknown event: {ev.theType}"

# Utility functions
proc convertKey*(wm: Whim, keystr: cstring): cint =
  # Convert the key string into a XKeyCode
  cint(XKeysymToKeycode(wm.dpy, XStringToKeysym(keystr)))

proc getXKeycode*(wm: Whim, sym: KeySym): KeyCode = XKeysymToKeycode(wm.dpy, sym)

#[
  Wrapper functions around XGrabKey and XGrabButton
]#
proc grabKey*(wm: Whim, code: int, modMask: int) =
  discard XGrabKey(
      wm.dpy, 
      cint(code),
      cuint(modMask),
      wm.root,
      1,
      GrabModeAsync,
      GrabModeAsync)

proc grabButton*(wm: Whim, w: Window, button: int, modMask: int, buttonMask: int) = 
  discard XGrabButton(
      wm.dpy,
      cuint(button),
      cuint(modMask),
      w,
      1,
      cuint(buttonMask),
      GrabModeAsync,
      GrabModeAsync,
      None,
      None)

proc frameWindow*(wm: Whim, w: Window) =
  var 
    attrs: XWindowAttributes
  
  const 
    BorderWidth = 5
    BorderColor = 0xff0000
    BgColor = 0x0000ff
  
  # Retrieve attribute of window to frame
  discard XGetWindowAttributes(wm.dpy, w, attrs.addr)

  # Create frame
  let frame = XCreateSimpleWindow(
      wm.dpy,
      wm.root,
      attrs.x,
      attrs.y,
      attrs.width.cuint,
      attrs.height.cuint,
      BorderColor,
      BorderWidth,
      BgColor)
      
  # Select events on the frame
  discard XSelectInput(wm.dpy, frame,
                       SubstructureNotifyMask or SubstructureRedirectMask)

  discard XAddToSaveSet(wm.dpy, w)

  # Reparent client window
  discard XReparentWindow(
      wm.dpy,
      w,
      frame,
      0, 0) # offset of client window within frame

  # Map frame
  discard XMapWindow(wm.dpy, frame)

  echo "framed window!"

  wm.grabButton(w, 1, Mod1Mask, ButtonPress or ButtonReleaseMask or ButtonMotionMask)
  wm.grabButton(w, 3, Mod1Mask, ButtonPress or ButtonReleaseMask or ButtonMotionMask)

proc makeKeyMapping*(wm: Whim, ev: XKeyEvent): KeyMapping = 
  KeyMapping(code: cint(ev.keycode), modMask: cast[int](ev.state))