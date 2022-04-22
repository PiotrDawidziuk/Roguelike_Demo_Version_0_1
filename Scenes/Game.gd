extends Node2D

const WALKERS_STEPS = 200

var borders = Rect2(1,1, 38, 21)

onready var tileMap = $TileMap

func _ready():
	randomize()
	generate_level()

func generate_level():
	var walker = Walker.new(Vector2(19,11), borders)
	var map = walker.walk(WALKERS_STEPS)
	walker.queue_free()
	for location in map:
		tileMap.set_cellv(location, -1)
	tileMap.update_bitmask_region(borders.position, borders.end)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
