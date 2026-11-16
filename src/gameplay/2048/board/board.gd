extends Node2D
class_name Board

const TILE_SIZE: float = 64.0
const SEPARATION: float = 5.0

@onready var camera_service: CameraService = Services.get(CameraService.SERVICE_ID)

var tiles: Array[Tile] = []

var move_debounce: bool = false

func _ready() -> void:
	add_random_tile(2)

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("down"): apply_move(0)
	if Input.is_action_just_pressed("right"): apply_move(1)
	if Input.is_action_just_pressed("up"): apply_move(2)
	if Input.is_action_just_pressed("left"): apply_move(3)
	# if Input.is_action_just_pressed("ui_accept"): add_random_tile(2)
	pass

func apply_move(dir: int) -> void:
	var moves: int = 0

	if move_debounce: return
	if dir == 0:
		for y: int in range(3, -1, -1):
			for x: int in 4:
				var target: Vector2i = Vector2i(x, y)
				if not is_tile_empty(target):
					if get_tile(target).move(dir): moves += 1
	if dir == 1:
		for y: int in 4:
			for x: int in range(3, -1, -1):
				var target: Vector2i = Vector2i(x, y)
				if not is_tile_empty(target):
					if get_tile(target).move(dir): moves += 1
	if dir == 2:
		for y: int in 4:
			for x: int in 4:
				var target: Vector2i = Vector2i(x, y)
				if not is_tile_empty(target):
					if get_tile(target).move(dir): moves += 1
	if dir == 3:
		for y: int in 4:
			for x: int in 4:
				var target: Vector2i = Vector2i(x, y)
				if not is_tile_empty(target):
					if get_tile(target).move(dir): moves += 1

	move_debounce = true
	await get_tree().create_timer(0.1).timeout
	move_debounce = false
	if moves > 0:
		add_random_tile(2)
		camera_service.screen_shake(5, 0.05)

func resolve_position(pos: Vector2i) -> Vector2:
	# return (pos * TILE_SIZE) + ((TILE_SIZE / 2) * Vector2i.ONE) - ((TILE_SIZE * 2) * Vector2.ONE)
	return Vector2(pos * (TILE_SIZE + SEPARATION)) + Vector2.ONE * (TILE_SIZE / 2.0 - (4 * TILE_SIZE + 3 * SEPARATION) / 2.0)

func is_tile_empty(pos: Vector2i) -> bool:
	return tiles.filter(func(t: Tile) -> bool: return t.tile_pos == pos and !t.to_merge).is_empty()

func get_tile(pos: Vector2i) -> Tile:
	return tiles.filter(func(t: Tile) -> bool: return t.tile_pos == pos and !t.to_merge).get(0)

func get_empty_pos() -> Array[Vector2i]:
	var empty: Array[Vector2i] = []
	
	for y: int in 4:
		for x: int in 4:
			# print(is_tile_empty(Vector2i(x, y)))
			if is_tile_empty(Vector2i(x, y)):
				empty.append(Vector2i(x, y))
	
	return empty

func remove_tile(tile: Tile) -> void:
	tiles.erase(tile)
	tile.queue_free.call_deferred()

func add_random_tile(value: int) -> void:
	var random_pos: Array[Vector2i] = get_empty_pos()
	if random_pos.is_empty(): return
	var random: Vector2i = random_pos.pick_random()
	add_tile(random, value)

func add_tile(pos: Vector2i, value: int) -> void:
	if not is_tile_empty(pos): return
	var tile: Tile = Tile.create(pos, value, self)
	add_child(tile)
	tiles.append(tile)