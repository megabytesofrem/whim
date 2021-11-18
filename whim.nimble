# Package

version       = "0.1.0"
author        = "megabytesofrem"
description   = "Small window manager in Nim"
license       = "MIT"
srcDir        = "src"
bin           = @["whim"]


# Dependencies
requires "x11 == 1.1"
requires "nim >= 1.6.0"

task testwm, "Runs the window manager in Xephyr":
    exec "sh test.sh"