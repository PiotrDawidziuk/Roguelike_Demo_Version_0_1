extends Node2D


const Player = preload("res://Scenes/hero.tscn")
const Secret = preload("res://Scenes/secret.tscn")
const WALKERS_STEPS = 200

#TEST VARIABLES
var cell_sample
onready var test_label = $Label
var cell_table = []
var cell_dict = {}
var secret = Secret.instance()

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
	player.position = initial_position
	walker.queue_free()
	for location in map:
		tileMap.set_cellv(location, 0)
		var new_cell = MapClasses.MapCellProperties.new()
		new_cell.position = location
		new_cell.tile_type = 0
		cell_table.append(new_cell)
		cell_dict[new_cell.position] = new_cell
		

	add_child(secret)
	secret.position = cell_table[30].position*32
	
	tileMap.set_cellv(Vector2(1,1), -1)
	
	cell_sample = MapClasses.MapCellProperties.new()
		
	tileMap.update_bitmask_region(borders.position, borders.end)
	
	cell_sample = tileMap.get_cell(2,2)
	# test_label.text = String(cell_sample)
	test_label.text = "Welcome Adventurer!"

func _input(event):
	if event.is_action_pressed("ui_left"):
		if cell_dict.has(Vector2((player.position.x / 32) -1, player.position.y / 32)):
			var test_text_1 = String(cell_dict[Vector2(player.position.x / 32, player.position.y / 32)].position) 
			test_label.text = "You went West from " + test_text_1
			player.position = Vector2(player.position.x -32, player.position.y)
	if event.is_action_pressed("ui_right"):
		if cell_dict.has(Vector2((player.position.x / 32) +1, player.position.y / 32)):
			var test_text_1 = String(cell_dict[Vector2(player.position.x / 32, player.position.y / 32)].position) 
			test_label.text = "You went East from " + test_text_1
			player.position = Vector2(player.position.x +32, player.position.y)
	if event.is_action_pressed("ui_up"):
		if cell_dict.has(Vector2(player.position.x / 32, (player.position.y / 32)-1)):
			var test_text_1 = String(cell_dict[Vector2(player.position.x / 32, player.position.y / 32)].position) 
			test_label.text = "You went North from " + test_text_1
			player.position = Vector2(player.position.x, player.position.y - 32)
	if event.is_action_pressed("ui_down"):
		if cell_dict.has(Vector2(player.position.x / 32, (player.position.y / 32)+1)):
			var test_text_1 = String(cell_dict[Vector2(player.position.x / 32, player.position.y / 32)].position) 
			test_label.text = "You went South from" + test_text_1
			player.position = Vector2(player.position.x, player.position.y + 32)
	meeting(player.position)

func meeting(position):
	if secret != null && position == secret.position:
		test_label.text = "You found something!"
		secret.queue_free()
		
