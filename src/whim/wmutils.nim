#[
  Whim - Minimal floating window manager in Nim. 
  Based off of https://github.com/mackstann/tinywm.
]#

import types
import x11/x, x11/xlib 

# Utility functions

proc convertKey*(dpy: PDisplay, keystr: cstring): cint =
  # Convert the key string into a XKeyCode
  cint(XKeysymToKeycode(dpy, XStringToKeysym(keystr)))

proc getXKeycode*(dpy: PDisplay, sym: KeySym): KeyCode = XKeysymToKeycode(dpy, sym)

#[
  Wrapper functions around XGrabKey and XGrabButton
]#
proc grabKey*(dpy: PDisplay, code: int, modMask: int) =
  discard XGrabKey(
      dpy, 
      cint(code),
      cuint(modMask),
      DefaultRootWindow(dpy),
      1,
      GrabModeAsync,
      GrabModeAsync)

proc grabButton*(dpy: PDisplay, button: int, modMask: int, buttonMask: int) = 
  discard XGrabButton(
      dpy,
      cuint(button),
      cuint(modMask),
      DefaultRootWindow(dpy),
      1,
      cuint(buttonMask),
      GrabModeAsync,
      GrabModeAsync,
      None,
      None)

proc makeKeyMapping*(dpy: PDisplay, keystr: cstring, modMask: int): KeyMapping =
  var key = convertKey(dpy, keystr)
  KeyMapping(code: key, modMask: modMask)

proc makeKeyMapping*(ev: XKeyEvent): KeyMapping = 
  KeyMapping(code: cint(ev.keycode), modMask: cast[int](ev.state))