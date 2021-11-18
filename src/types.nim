import tables, x11/xlib

type
  KeyMapping* = object
    code*: int
    modMask*: int

  Command* = object
    # The command name. You can specify this if you want, or you can use
    # a wrapper function defined below to sweeten the syntax a bit
    name: string

    # Arguments for the command
    args: seq[string]


  Whim* = object
    dpy*: PDisplay
    keys*: Table[KeyMapping, Command]

proc makeCommand*(name: string, args: seq[string]): Command =
  Command(name: name, args: args)

#[
  Aliases for makeCommand to sweeten the syntax a little
]#

proc shell*(args: seq[string]): Command =
  Command(name: "shell", args: args)

proc raiseW*(): Command =
  Command(name: "raiseW", args: @[])
