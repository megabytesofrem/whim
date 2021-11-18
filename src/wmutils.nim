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

proc grabKey*(dpy: PDisplay, code: int, modMask: int) =
  discard XGrabKey(
      dpy, 
      cint(code),
      cuint(modMask),
      DefaultRootWindow(dpy),
      1,
      GrabModeAsync,
      GrabModeAsync)

proc makeKeyMapping*(dpy: PDisplay, code: cstring, modMask: int): KeyMapping =
  var key = cint(XKeysymToKeycode(dpy, XStringToKeysym(code)))
  KeyMapping(code: key, modMask: modMask)

proc makeKeyMapping*(ev: XKeyEvent): KeyMapping = 
  KeyMapping(code: cint(ev.keycode), modMask: cast[int](ev.state))