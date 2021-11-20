type
  Vector2* = object
    x*: int
    y*: int
  
  ## Position and size are just Vector2s
  Position* = Vector2
  Size* = Vector2

## Initializer
proc initVector*(x: int, y: int): Vector2 {.noSideEffect.} =
  Vector2(x: x, y: y)

proc initPosition*(x: int, y: int): Position {.noSideEffect.} =
  initVector(x, y)

proc `+`*(v1: Vector2, v2: Vector2): Vector2 {.noSideEffect.} =
  initVector(v1.x + v2.x, v1.y + v2.y)

proc `-`*(v1: Vector2, v2: Vector2): Vector2 {.noSideEffect.} =
  initVector(v1.x - v2.x, v1.y - v2.y)

