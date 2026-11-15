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

func furthest_move_down_point(pos: Vector2i) -> Vector2i:
	while pos.y < 3 and get_cell(Vector2i(pos.x, pos.y + 1)) == EMPTY:
		pos.y += 1
	return pos

## Rotates clockwise once,
## 1 Time  =  Right face down
## 2 Times =  Top face down
## 3 Times =  Left face down
func rotate_cw() -> void:
	var new_grid: Projection = Projection()
	for y: int in 4:
		for x: int in 4:
			new_grid[x][3 - y] = get_cell(Vector2i(x, y))
	_grid = new_grid

func vector_rotate_cw(pos: Vector2i) -> Vector2i: return Vector2i(3 - pos.y, pos.x)
func vector_rotate_ccw(pos: Vector2i) -> Vector2i: return Vector2i(pos.y, 3 - pos.x)

func rotate_ccw() -> void:
	for _i: int in 3:
		rotate_cw()

class Move:
	var from: Vector2i
	var to: Vector2i
	var merge: bool

	func _init(p_from: Vector2i, p_to: Vector2i, p_merge: bool) -> void:
		from = p_from
		to = p_to
		merge = p_merge

	func _to_string() -> String:
		return "Move(To = %v, From = %v, Merge = %s)" % [to, from, merge]

func normalize_move_rotation(move: Move, dir: int) -> Move:
	for _i: int in dir:
		move.from = vector_rotate_ccw(move.from)
		move.to = vector_rotate_ccw(move.to)
	return move

func normalize_moves_rotation(moves: Array[Move], dir: int) -> void:
	for move: Move in moves:
		normalize_move_rotation(move, dir)

## Direction:
## DOWN  0 (Do zero rotations) 
## RIGHT 1 (Do one rotation)
## UP    2 (Do two rotations)
## LEFT  3 (Do three rotations)
func perform_move(moves: Array[Move], dir: int, merge: bool = true) -> void:
	var merged: bool = false
	# First rotate the board
	for _i: int in dir:
		rotate_cw()

	for y: int in range(2, -1, -1):
		for x: int in range(0, 4, 1):
			var origin: Vector2i = Vector2i(x, y)
			if get_cell(origin) != EMPTY:
				var dest: Vector2i = furthest_move_down_point(origin)
				if dest != Vector2i(x, y):
					set_cell(dest, get_cell(origin))
					set_cell(origin, EMPTY)
					var matches: Array[Move] = moves.filter(func(m: Move) -> bool: return m.to == origin)
					var move: Move = null
					if !matches.is_empty():
						move = matches.get(0)
					
					if move:
						move.to = dest
					else:
						moves.append(Move.new(origin, dest, false))
	
	if merge:
		for y: int in range(2, -1, -1):
			for x: int in range(0, 4, 1):
				var origin: Vector2i = Vector2i(x, y)
				if get_cell(origin) != EMPTY:
					var dest: Vector2i = Vector2i(x, y + 1)
					if y < 3 and get_cell(dest) == get_cell(origin):
						set_cell(dest, get_cell(origin) * 2)
						set_cell(origin, EMPTY)
						merged = true

						var matches: Array[Move] = moves.filter(func(m: Move) -> bool: return m.to == origin)
						var move: Move = null
						if !matches.is_empty():
							move = matches.get(0)
						
						if move:
							move.to = dest
							move.merge = true
						else:
							moves.append(Move.new(origin, dest, true))

	# Return the board to its normal orientation
	for _i: int in dir:
		rotate_ccw()

	if merged:
		perform_move(moves, dir, false)
