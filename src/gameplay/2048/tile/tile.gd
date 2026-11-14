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

@export var value: int = 0

@onready var value_label: Label = %Value

static func create(p_value: int) -> Tile:
	var tile: Tile = SCENE.instantiate()
	tile.value = p_value
	return tile

func _ready() -> void:
	if value in COLORS:
		self_modulate = COLORS[value]
	else:
		self_modulate = COLORS[-1]
	
	value_label.text = str(value)