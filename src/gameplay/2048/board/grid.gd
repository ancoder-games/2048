extends RefCounted
class_name Grid4x4

## Wraps a projection

const EMPTY: int = -1
const EMPTY_ROW: Vector4 = Vector4(EMPTY, EMPTY, EMPTY, EMPTY)

var _grid: Projection

func _init() -> void:
    _grid = Projection(EMPTY_ROW, EMPTY_ROW, EMPTY_ROW, EMPTY_ROW)

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

func _to_string() -> String:
    return str(_grid)