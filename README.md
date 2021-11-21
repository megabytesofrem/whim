# whim
Small window manager in Nim. Floating for now, but tiling may be added later on

## Why?
I wrote `whim` while learning Nim because I wanted to create a window manager.
The goals of Whim is to be:
1. Simple, in terms of having easy to understand code as well as being easy to use
2. Lightweight. Don't add what isn't needed and avoid feature creep
3. Hackable. Whim should be configurable entirely within Nim similar to Xmonad and dwm.


## Running with Xephyr
You can test out `whim` by running it using Xephyr. 
```sh
$ nimble testwm
```

### Configuring Whim
Whim can be configured by hacking on `whim.nim`. An example config that binds some keys to
launch a terminal, browser and xeyes is shown below.
```nim
##
## Whim - Hackable window manager in Nim. 
##

## Whim is hackable, configure it in this file!

# Import core components
import std/[strformat, tables, osproc]

import x11/[x, xlib, keysym]
import core/[wm, wm_types, input, wrappers]

var
  whim: WM

proc initWhim() =
  whim = initWm()

proc userConfig(wm: var WM) =
  # spawn nitrogen for a wallpaper
  discard execCmd("nitrogen --restore &")
 
  # Mod1Mask is the Alt key
  # format:     key     modifier    command
  defineKeybind(XKc_E, Mod1Mask, "xeyes &")
  defineKeybind(XKc_T, Mod1Mask, "xrdb ~/.Xresources && urxvt &")
  defineKeybind(XKc_F, Mod1Mask, "firefox &")

when isMainModule:
  echo "Initializing WM"
  initWhim()
  whim.userConfig()

  for key, cmd in whim.bindings:
    echo &"Registering key {key} -> {cmd}"
    whim.grabKey(key.code, key.modMask.uint)

  whim.doMainLoop()
```

### TODO
- [x] Implement a small DSL/config file written in Nim
- [x] Add movement of windows
- [x] Draw window decorations
- [ ] Add support for EWMH
- [ ] Add support for tiling windows (like i3)