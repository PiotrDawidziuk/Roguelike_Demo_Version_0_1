extends Node2D


#const Player = preload("res://Scenes/hero.tscn")
const Secret = preload("res://Scenes/secret.tscn")
const Exit = preload("res://Scenes/level_exit.tscn")
const WALKERS_STEPS = 200

#TEST VARIABLES
var cell_sample # not needed

#needed variables
var cell_table = []
var cell_dict = {}
var secret = Secret.instance()
var exit = Exit.instance()

#variables of things player has etc:
var hasKey = false
#var points = Globals.points

var borders = Rect2(1,1, 38, 21)

onready var tileMap = $TileMap

onready var player = $hero
onready var message_box = $hero/Label
onready var points_label = $hero/PointsLabel
onready var gold_label = $hero/GoldLabel
onready var key = $key


func _ready():
	randomize()
	generate_level()

func generate_level():
	var walker = Walker.new(Vector2(19,11), borders)
	var map = walker.walk(WALKERS_STEPS)
	#add_child(player)
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
	cell_dict[Vector2(secret.position.x / 32, secret.position.y / 32)].searched_description = 'You found 100 gold pieces'
	cell_dict[Vector2(secret.position.x / 32, secret.position.y / 32)].gold = 100
	cell_dict[Vector2(secret.position.x / 32, secret.position.y / 32)].isEmpty = false
	
	
	add_child(exit)
	#exit.position = cell_table[40].position*32
	exit.position = walker.get_end_room().position*32
	
	key.position = cell_table[20].position*32
	
	tileMap.set_cellv(Vector2(1,1), -1)
	
	cell_sample = MapClasses.MapCellProperties.new()
		
	tileMap.update_bitmask_region(borders.position, borders.end)
	
	cell_sample = tileMap.get_cell(2,2)
	# message_box.text = String(cell_sample)
	message_box.text = "Welcome Adventurer!"
	points_label.text = "Points: " + String(Globals.points)

func reaload_level():
	get_tree().reload_current_scene()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		reaload_level()
	if event.is_action_pressed("ui_left"):
		if cell_dict.has(Vector2((player.position.x / 32) -1, player.position.y / 32)):
			var test_text_1 = String(cell_dict[Vector2(player.position.x / 32, player.position.y / 32)].position) 
			message_box.text = "You went West from " + test_text_1
			player.position = Vector2(player.position.x -32, player.position.y)
	if event.is_action_pressed("ui_right"):
		if cell_dict.has(Vector2((player.position.x / 32) +1, player.position.y / 32)):
			var test_text_1 = String(cell_dict[Vector2(player.position.x / 32, player.position.y / 32)].position) 
			message_box.text = "You went East from " + test_text_1
			player.position = Vector2(player.position.x +32, player.position.y)
	if event.is_action_pressed("ui_up"):
		if cell_dict.has(Vector2(player.position.x / 32, (player.position.y / 32)-1)):
			var test_text_1 = String(cell_dict[Vector2(player.position.x / 32, player.position.y / 32)].position) 
			message_box.text = "You went North from " + test_text_1
			player.position = Vector2(player.position.x, player.position.y - 32)
	if event.is_action_pressed("ui_down"):
		if cell_dict.has(Vector2(player.position.x / 32, (player.position.y / 32)+1)):
			var test_text_1 = String(cell_dict[Vector2(player.position.x / 32, player.position.y / 32)].position) 
			message_box.text = "You went South from" + test_text_1
			player.position = Vector2(player.position.x, player.position.y + 32)
	meeting(player.position)
	if event.is_action_pressed("search"):
		search(cell_dict[Vector2(player.position.x / 32, player.position.y / 32)])
		#message_box.text = "Search clicked"
		
	

func meeting(position):
	if secret != null && position == secret.position:
		message_box.text = "You found something!"
		Globals.points = Globals.points + 1
		points_label.text = "Points: " + String(Globals.points)
		secret.queue_free()
	if key != null && position == key.position:
		message_box.text = "You found a key!"
		hasKey = true
		key.queue_free()	
	if exit != null && position == exit.position:
		if (hasKey):
			reaload_level()
		else:
			message_box.text = "The exit is locked!"
func search(cell):
	message_box.text = cell.searched_description
	if (!cell.isEmpty):
		if (cell.gold != 0):
			Globals.gold += cell.gold
			gold_label.text = "Gold: " + String(Globals.gold)
