extends Node2D
class_name Board

const TILE_SIZE: float = 64.0
const SEPARATION: float = 5.0

@onready var camera_service: CameraService = Services.get(CameraService.SERVICE_ID)

@onready var anim: AnimationPlayer = %AnimationPlayer
@onready var retry_button: Button = %RetryButton
@onready var score_label: Label = %ScoreLabel
@onready var high_score_label: Label = %HighScoreLabel

var tiles: Array[Tile] = []

var score: int = 0:
	set(value): score = value; _on_score_updated()
var high_score: int = 0

var game_over: bool = false

var move_debounce: bool = false

func _on_score_updated() -> void:
	if !is_node_ready(): return
	
	if score > high_score:
		high_score = score

	score_label.text = "Score: %d" % score
	high_score_label.text = "Hi Score: %d" % high_score

func _on_retry_button_pressed() -> void:
	anim.play("retry")
	await anim.animation_finished
	await get_tree().create_timer(0.2).timeout

	for y: int in 4:
		for x: int in 4:
			await get_tile(Vector2i(x, y)).destroy()
	
	await get_tree().create_timer(0.4).timeout

	add_random_tile(2)
	score = 0
	game_over = false

func _ready() -> void:
	retry_button.pressed.connect(_on_retry_button_pressed)

	_on_score_updated()
	add_random_tile(2)

func _physics_process(_delta: float) -> void:
	if game_over: return

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

	if check_game_over():
		game_over = true
		await get_tree().create_timer(1).timeout
		anim.play("game_over")

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
			if is_tile_empty(Vector2i(x, y)):
				empty.append(Vector2i(x, y))
	
	return empty

func get_tiles_can_merge() -> Array[Tile]:
	var merge: Array[Tile] = []

	for y: int in 4:
		for x: int in 4:
			var target: Vector2i = Vector2i(x, y)
			if !is_tile_empty(target) and get_tile(target).can_merge():
				merge.append(get_tile(target))

	return merge

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

func check_game_over() -> bool:
	return get_empty_pos().is_empty() and get_tiles_can_merge().is_empty()
