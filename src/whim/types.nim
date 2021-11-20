import std/tables
import x11/[x, xlib]

import vector

type
  KeyMapping* = object
    code*: KeyCode
    modMask*: int

  Command* = object
    # The command name. You can specify this if you want, or you can use
    # a wrapper function defined below to sweeten the syntax a bit
    name*: string

    # Arguments for the command
    args*: seq[string]

  Whim* = object
    dpy*: PDisplay
    root*: Window
    keys*: Table[KeyMapping, Command]
    clients*: Table[Window, Window]

    dragStartPos*: Position
    dragStartFramePos*: Position

proc initCommand*(name: string, args: seq[string]): Command =
  Command(name: name, args: args)

#[
  Aliases for makeCommand to sweeten the syntax a little
]#

proc shell*(args: seq[string]): Command = initCommand("shell", args)
proc raiseW*(): Command = initCommand("raiseW", @[])
