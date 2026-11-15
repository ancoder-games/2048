extends Node2D

const TILE_SIZE: float = 64.0

var board: Grid4x4 = Grid4x4.new()
var tiles: Dictionary[Vector2i, Tile] = {}

func _ready() -> void:
	add_random_value(2)

func _physics_process(_delta: float) -> void:
	# if Input.is_action_just_pressed("down"): apply_move(0)
	# if Input.is_action_just_pressed("right"): apply_move(1)
	# if Input.is_action_just_pressed("up"): apply_move(2)
	# if Input.is_action_just_pressed("left"): apply_move(3)
	# if Input.is_action_just_pressed("ui_accept"): add_random_value(2); _render()
