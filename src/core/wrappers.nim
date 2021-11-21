##
## Wrappers around the ugly X11 API
## 

import std/strformat
import wm_types
import x11/[x, xlib, keysym]

## Converters
converter keycodeToC*(x: KeyCode): cint = cint(x)

converter intToC*(x: int): cint = cint(x)
converter uintToC*(x: uint): cuint = cuint(x)
converter boolToXBool*(x: bool): XBool = XBool(x)

proc `$`*(e: XEvent): string {.noSideEffect.} =
  case e.theType:
  of KeyPress:  return "KeyPress"
  of KeyRelease: return "KeyRelease"
  of ButtonPress: return "ButtonPress"
  of ButtonRelease: return "ButtonRelease"
  of MotionNotify: return "MotionNotify"
  of CreateNotify: return "CreateNotify"
  of DestroyNotify: return "DestroyNotify"
  else: return &"Unknown event: {e.theType}"

## Wrappers around XGrabKey and XGrabButton

proc grabKey*(wm: WM, code: KeyCode, modMask: uint) =
  discard XGrabKey(
      wm.display,
      code,
      modMask,
      wm.root,
      true,
      GrabModeAsync,
      GrabModeAsync
  )

proc grabButton*(wm: WM, win: Window, button: uint, 
                modMask: uint, 
                buttonMask: uint) =
  discard XGrabButton(
      wm.display,
      button,
      modMask,
      win,
      true,
      buttonMask,
      GrabModeAsync,
      GrabModeAsync,
      None,
      None
  )