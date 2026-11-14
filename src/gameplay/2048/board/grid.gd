extends RefCounted
class_name Grid4x4

## Wraps a projection

const EMPTY: int = -1
const EMPTY_ROW: Vector4 = Vector4(EMPTY, EMPTY, EMPTY, EMPTY)

var _grid: Projection

func _init() -> void:
    _grid = Projection(EMPTY_ROW, EMPTY_ROW, EMPTY_ROW, EMPTY_ROW)

func _to_string() -> String:
    return str(_grid)

func get_cell(pos: Vector2i) -> int:
    return _grid[pos.y][pos.x]

func set_cell(pos: Vector2i, value: int) -> void:
    _grid[pos.y][pos.x] = value

func get_available_cells() -> Array[Vector2i]:
    var empty: Array[Vector2i]
    for y: int in 4:
        for x: int in 4:
            if get_cell(Vector2i(x, y)) == EMPTY:
                empty.append(Vector2i(x, y))
    return empty

func move_down() -> void:
    pass

## Rotates clockwise once,
## 1 Time  =  Left face down
## 2 Times =  Top face down
## 3 Times =  Right face down
func rotate_cw() -> void:
    var new_grid: Projection = Projection()
    for y: int in 4:
        for x: int in 4:
            new_grid[3 - y][x] = get_cell(Vector2i(x, y))
    _grid = new_grid

## Rotates counter-clockwise once,
## 1 Time  =  Left face down
## 2 Times =  Top face down
## 3 Times =  Right face down
func rotate_ccw() -> void:
    for _i: int in 3:
        rotate_cw()