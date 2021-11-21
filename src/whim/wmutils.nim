#[
  Whim - Minimal floating window manager in Nim. 
  Based off of https://github.com/mackstann/tinywm.
]#

import types
import std/[strformat, tables, macros]

import x11/[xlib, x, keysym]

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

proc getXKeycode*(wm: Whim, sym: KeySym): KeyCode = XKeysymToKeycode(wm.dpy, sym)

#[
  Wrapper functions around XGrabKey and XGrabButton
]#
proc grabKey*(wm: Whim, code: KeyCode, modMask: int) =
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

proc frameWindow*(wm: var Whim, w: Window) =
  var 
    attrs: XWindowAttributes
  
  const 
    BorderWidth = 3
    BorderColor = 0x00ff00
    BgColor = 0xffffff
  
  # Retrieve attribute of window to frame
  discard XGetWindowAttributes(wm.dpy, w, attrs.addr)

  # Create frame
  let frame = XCreateSimpleWindow(
      wm.dpy,                     # display
      wm.root,                    # parent
      attrs.x,                    # x
      attrs.y,                    # y
      attrs.width.cuint,          # width
      attrs.height.cuint,         # height
      BorderWidth,                # border size
      BorderColor,                # border color
      BgColor)                    # bg color
      
  let decoration = XCreateSimpleWindow(
      wm.dpy,                     # display
      frame,                      # parent
      0,                          # x
      0,                          # y
      attrs.width.cuint,          # width
      15,                         # height
      BorderWidth,                # border size
      0x0000ff,                   # border color
      0x0000ff)                   # bg color

  # Select events on the frame
  discard XSelectInput(wm.dpy, frame,
                       SubstructureNotifyMask or SubstructureRedirectMask)

  discard XAddToSaveSet(wm.dpy, w)

  discard XReparentWindow(
      wm.dpy,           # display
      decoration,       # child
      frame,            # parent
      0, 0)

  discard XReparentWindow(
      wm.dpy,           # display
      w,                # child
      frame,            # parent
      0, 15) # offset of client window within frame

  echo "framed window!"
  wm.clients[w] = frame

  # Map frame
  discard XMapWindow(wm.dpy, frame)

  wm.grabButton(w, 1, Mod1Mask, ButtonPress or ButtonReleaseMask or ButtonMotionMask)
  wm.grabButton(w, 3, Mod1Mask, ButtonPress or ButtonReleaseMask or ButtonMotionMask)

proc makeKeyMapping*(wm: Whim, ev: XKeyEvent): KeyMapping = 
  KeyMapping(code: cuchar(ev.keycode), modMask: int(ev.state))