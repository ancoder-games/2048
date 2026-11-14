class_name Tile
extends Sprite2D

const SCENE: PackedScene = preload("uid://ccxy34shwjvac")

@export var value: int = 0

static func create(p_value: int) -> Tile:
	var tile: Tile = SCENE.instantiate()
	tile.value = p_value
	return tile