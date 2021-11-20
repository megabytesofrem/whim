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

### TODO
- [x] Implement a small DSL/config file written in Nim
- [x] Add movement of windows
- [ ] Somehow draw window decorations
- [ ] Add support for tiling windows (like i3)