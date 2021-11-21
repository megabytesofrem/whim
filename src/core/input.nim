##
## Wrappers around the ugly X11 API
## 

import wm_types
import x11/[x, xlib]

# KeyCode is apparently deprecated, but we don't care for now
{.push warning[Deprecated]: off.}

proc newKeyMapping*(code: KeyCode, modMask: uint): KeyMapping =
  KeyMapping(code: code, modMask: modMask.int)

proc symToKeyCode*(wm: WM, sym: KeySym): KeyCode =
  XKeysymToKeycode(wm.display, sym)

template defineKeybind*(keysym: KeySym, modMsk: int, binding: string) =
  wm.bindings[KeyMapping(code: XKeysymToKeycode(wm.display, keysym), modMask: modMsk)] = binding

{.pop.}