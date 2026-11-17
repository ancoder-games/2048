class_name Tile
extends Sprite2D

const SCENE: PackedScene = preload("uid://ccxy34shwjvac")

const COLORS: Dictionary[int, Color] = {
	2: Color8(181, 181, 181),
	4: Color8(165, 219, 76),
	8: Color8(219, 153, 76),
	16: Color8(84, 213, 219),
	32: Color8(84, 102, 219),
	64: Color8(168, 84, 219),
	128: Color8(219, 84, 84),
	256: Color8(84, 219, 123),
	512: Color8(215, 84, 219),
	1024: Color8(84, 136, 219),
	2048: Color8(219, 210, 84),
	-1: Color8(51, 51, 51), # #333333
}

const DIRECTIONS: Dictionary[int, Vector2i] = {
	0: Vector2i(0, 1), # DOWN
	1: Vector2i(1, 0), # RIGHT
	2: Vector2i(0, -1), # UP
	3: Vector2i(-1, 0), # LEFT
}

@export var value: int = 0:
	set(new_value): value = new_value; _tile_value_updated()
@export var tile_pos: Vector2i:
	set(new_value): tile_pos = new_value; _tile_pos_updated()

@onready var value_label: Label = %Value
@onready var anim: AnimationPlayer = %AnimationPlayer

var board: Board
var tween: Tween

var to_merge: bool = false
var to_play_merge: bool = false

static func create(p_tile_pos: Vector2i, p_value: int, p_board: Board) -> Tile:
	var tile: Tile = SCENE.instantiate()
	tile.value = p_value
	tile.tile_pos = p_tile_pos
	tile.board = p_board
	return tile

func _tile_pos_updated(do_tween: bool = true) -> void:
	if not is_node_ready(): return
	
	if tween and tween.is_valid():
		tween.kill()
	
	if do_tween:
		tween = create_tween()
		tween.tween_property(self, "position", board.resolve_position(tile_pos), 0.1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		if to_merge:
			await tween.finished
			board.remove_tile(self)
	else:
		position = board.resolve_position(tile_pos)

func _tile_value_updated() -> void:
	if not is_node_ready(): return

	if value in COLORS:
		self_modulate = COLORS[value]
	else:
		self_modulate = COLORS[-1]
	
	value_label.text = str(value)

	if to_play_merge:
		anim.play("merge")
		to_play_merge = false

func _ready() -> void:
	_tile_pos_updated(false)
	_tile_value_updated()

func destroy() -> void:
	anim.play("destroy")
	await anim.animation_finished
	board.remove_tile(self)

func can_merge() -> bool:
	for dir: Vector2i in DIRECTIONS.values():
		var test_pos: Vector2i = tile_pos + dir
		if test_pos.x >= 0 and test_pos.x <= 3 and test_pos.y >= 0 and test_pos.y <= 3:
			if !board.is_tile_empty(test_pos) and board.get_tile(test_pos).value == value:
				return true
	return false

func move(dir: int) -> bool:
	var moved: bool = false
	
	var new_pos: Vector2i = tile_pos
	
	while (dir == 3 and new_pos.x > 0) or (dir == 1 and new_pos.x < 3) or (dir == 2 and new_pos.y > 0) or (dir == 0 and new_pos.y < 3):
		var target: Vector2i = new_pos + DIRECTIONS[dir]
		if board.is_tile_empty(target):
			moved = true
			new_pos = target
		else:
			if board.get_tile(target).value == value:
				to_merge = true
				moved = true
				board.get_tile(target).to_play_merge = true
				board.get_tile(target).value *= 2
				board.score += board.get_tile(target).value
			break

	tile_pos = new_pos

	return moved
