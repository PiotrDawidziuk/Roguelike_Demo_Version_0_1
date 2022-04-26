extends Node2D


const Player = preload("res://Scenes/hero.tscn")
const Secret = preload("res://Scenes/secret.tscn")
const WALKERS_STEPS = 200

#TEST VARIABLES
var cell_sample
onready var test_label = $Label
var cell_table = []
var cell_dict = {}

var borders = Rect2(1,1, 38, 21)

onready var tileMap = $TileMap

var player = Player.instance()


func _ready():
	randomize()
	generate_level()

func generate_level():
	var walker = Walker.new(Vector2(19,11), borders)
	var map = walker.walk(WALKERS_STEPS)
	add_child(player)
	var initial_position = map.front()*32
	player.position = Vector2(initial_position.x -16, initial_position.y - 16)
	walker.queue_free()
	for location in map:
		tileMap.set_cellv(location, 0)
		var new_cell = MapClasses.MapCellProperties.new()
		new_cell.position = location
		new_cell.tile_type = 0
		cell_table.append(new_cell)
		cell_dict[position] = new_cell
		
	var secret = Secret.instance()
	add_child(secret)
	secret.position = cell_table[30].position*32
	
	tileMap.set_cellv(Vector2(1,1), -1)
	
	cell_sample = MapClasses.MapCellProperties.new()
		
	tileMap.update_bitmask_region(borders.position, borders.end)
	
	cell_sample = tileMap.get_cell(2,2)
	# test_label.text = String(cell_sample)
	test_label.text = "Example Text"

func _input(event):
	if event.is_action_pressed("ui_left"):
		var test_text_1 = String(cell_dict[position].position) 
		test_label.text = "You went West" + test_text_1
		player.position = Vector2(player.position.x -32, player.position.y)
	if event.is_action_pressed("ui_right"):
		test_label.text = "You went East"
		player.position = Vector2(player.position.x +32, player.position.y)
	if event.is_action_pressed("ui_up"):
		test_label.text = "You went North"
		player.position = Vector2(player.position.x, player.position.y - 32)
	if event.is_action_pressed("ui_down"):
		test_label.text = "You went South"
		player.position = Vector2(player.position.x, player.position.y + 32)	
