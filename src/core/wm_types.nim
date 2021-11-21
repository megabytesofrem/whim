import std/tables
import x11/[x, xlib]

import vector

type
  Client* = object
    ## will have other properties later on
    window*: Window

  KeyMapping* = object
    code*: KeyCode
    modMask*: int

  WM* = object
    display*: PDisplay
    root*: Window
    bindings*: Table[KeyMapping, string]

    ## table mapping X11 windows to Client types
    clients*: Table[Window, Client]
    
    dragStartPos*: Position
    dragStartFramePos*: Position

proc newClient*(win: Window): Client =
  Client(window: win)