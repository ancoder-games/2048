extends Node2D

const TILE_SIZE: float = 64.0

var board: Grid4x4 = Grid4x4.new()
var tiles: Dictionary[Vector2i, Tile] = {}

func _ready() -> void:
	add_random_value(2)

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("down"): apply_move(0)
	if Input.is_action_just_pressed("right"): apply_move(1)
	if Input.is_action_just_pressed("up"): apply_move(2)
	if Input.is_action_just_pressed("left"): apply_move(3)
	# if Input.is_action_just_pressed("ui_accept"): add_random_value(2); _render()


func apply_move(dir: int) -> void:
	var moves: Array[Grid4x4.Move] = []
	board.perform_move(moves, dir)
	board.normalize_moves_rotation(moves, dir)
	await animate_moves(moves)
	if not moves.is_empty():
		add_random_value(2)
	# _render()

func animate_moves(moves: Array[Grid4x4.Move]) -> void:
	if moves.is_empty(): return
	var tween: Tween = create_tween()
	for move: Grid4x4.Move in moves:
		var target: Tile = tiles[move.from]
		tween.parallel().tween_property(target, "position", pos_to_position(move.to), 0.1).set_ease(Tween.EASE_IN)
		if !move.merge:
			tiles.erase(move.from)
			tiles[move.to] = target

	await tween.finished
	
	for move: Grid4x4.Move in moves:
		if move.merge:
			tiles[move.from].queue_free()
			tiles[move.to].queue_free()
			tiles.erase(move.from)
			tiles.erase(move.to)
			add_value_at(move.to, board.get_cell(move.to))
		
func add_random_value(value: int) -> void:
	var free: Array[Vector2i] = board.get_available_cells()
	if free.is_empty(): return
	var random: Vector2i = free.pick_random()
	add_value_at(random, value)

func add_value_at(pos: Vector2i, value: int) -> void:
	board.set_cell(pos, value)
	add_tile(pos, value)

func add_tile(pos: Vector2i, value: int) -> void:
	var tile: Tile = Tile.create(value)
	tiles[pos] = tile
	add_child(tile)
	tile.position = pos_to_position(pos)

func pos_to_position(pos: Vector2i) -> Vector2:
	return (pos * TILE_SIZE) + ((TILE_SIZE / 2) * Vector2i.ONE) - ((TILE_SIZE * 2) * Vector2.ONE)

func _render() -> void:
	for tile: Tile in tiles.values():
		tile.queue_free()
	tiles.clear()
	
	for y: int in 4:
		for x: int in 4:
			var value: int = board.get_cell(Vector2i(x, y))
			if value != -1:
				add_tile(Vector2i(x, y), value)
