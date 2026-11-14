extends Node2D

const TILE_SIZE: float = 64.0

var board: Grid4x4 = Grid4x4.new()
var tiles: Dictionary[Vector2i, Tile] = {}

func _ready() -> void:
	add_random_value(2)

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		add_random_value(2)

func add_random_value(value: int) -> void:
	var free: Array[Vector2i] = board.get_available_cells()
	if free.is_empty(): return
	var random: Vector2i = free.pick_random()
	board.set_cell(random, value)
	add_tile(random, value)

func add_tile(pos: Vector2i, value: int) -> void:
	var tile: Tile = Tile.create(value)
	tiles[pos] = tile
	add_child(tile)
	tile.position = (pos * TILE_SIZE) + ((TILE_SIZE / 2) * Vector2i.ONE) - ((TILE_SIZE * 2) * Vector2.ONE)

## Direction:
## DOWN  0 (Do zero rotations) 
## RIGHT 1 (Do one rotation)
## UP    2 (Do two rotations)
## LEFT  3 (Do three rotations)
func perform_move(dir: int) -> void:
	# First rotate the board
	for _i: int in dir:
		board.rotate_cw()

	for y: int in range(2, 0, -1):
		for x: int in range(0, 4, 1):
			pass

	# Return the board to its normal orientation
	for _i: int in dir:
		board.rotate_ccw()