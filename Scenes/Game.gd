extends Node2D


#const Player = preload("res://Scenes/hero.tscn")
const Secret = preload("res://Scenes/secret.tscn")
const Exit = preload("res://Scenes/level_exit.tscn")
const Kobold = preload("res://Scenes/kobold.tscn")
const WALKERS_STEPS = 200

#TEST VARIABLES
var cell_sample # not needed

#needed variables
var cell_table = []
var cell_dict = {}
var npc_dict = {}
var secret = Secret.instance()
var exit = Exit.instance()
var kobold = Kobold.instance()
var rng = RandomNumberGenerator.new()

#variables of things player has etc:
var hasKey = false
#var points = Globals.points

var borders = Rect2(1,1, 38, 21)

onready var tileMap = $TileMap

onready var player = $hero
onready var message_box = $hero/Label
onready var points_label = $hero/PointsLabel
onready var gold_label = $hero/GoldLabel
onready var dialog_box = $hero/DialogBox
onready var dialog_text = $hero/DialogBox/DialogRect/DialogLabel


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
		var tileRand = rng.randi_range(1,100)
		if (tileRand < 80):
			tileMap.set_cell(location.x, location.y, 2, false, false, false, Vector2(0,0))
		elif (tileRand >= 80 && tileRand <= 85):
			tileMap.set_cell(location.x, location.y, 2, false, false, false, Vector2(1,0))
		elif (tileRand >= 85 && tileRand <= 90):
			tileMap.set_cell(location.x, location.y, 2, false, false, false, Vector2(2,0))
		elif (tileRand >= 95 && tileRand <= 97):
			tileMap.set_cell(location.x, location.y, 2, false, false, false, Vector2(3,0))
		else:
			tileMap.set_cell(location.x, location.y, 2, false, false, false, Vector2(4,0))
		var new_cell = MapClasses.MapCellProperties.new()
		new_cell.position = location
		new_cell.tile_type = 2
		cell_table.append(new_cell)
		cell_dict[new_cell.position] = new_cell
		

	# NPCs list
	
	# Add things:
	
	add_child(secret)
	secret.position = cell_table[30].position*32
	cell_dict[Vector2(secret.position.x / 32, secret.position.y / 32)].searched_description = 'You found 100 gold pieces'
	cell_dict[Vector2(secret.position.x / 32, secret.position.y / 32)].gold = 100
	cell_dict[Vector2(secret.position.x / 32, secret.position.y / 32)].isEmpty = false
	
	add_child(kobold)
	kobold.position = cell_table[33].position*32
	cell_dict[Vector2(kobold.position.x / 32, kobold.position.y / 32)].searched_description = 'You found kobold poop'
	cell_dict[Vector2(kobold.position.x / 32, kobold.position.y / 32)].isEmpty = false
	var koboldNPC =  Npc.NPC.new()
	koboldNPC.greeting = "Hello, I am Bobold the Kobold"
	koboldNPC.dialog = Npc.Dialog.new()
	koboldNPC.dialog.dialogPagesNumber = 2
	koboldNPC.dialog.dialogText[0] = "Hello, I am Bobold The Kobold"
	koboldNPC.dialog.dialogText[1] = "It would be really nice if I had some mushrooms"
	npc_dict[kobold.position] = koboldNPC
	
	add_child(exit)
	#exit.position = cell_table[40].position*32
	exit.position = walker.get_end_room().position*32
	
	key.position = cell_table[20].position*32
	
	tileMap.set_cellv(Vector2(1,1), -1)
	
	cell_sample = MapClasses.MapCellProperties.new()
		
	tileMap.update_bitmask_region(borders.position, borders.end)
	
	cell_sample = tileMap.get_cell(2,2)
	# message_box.text = String(cell_sample)
	if(Globals.levelNumber == 1):
		message_box.text = "Welcome Adventurer!"
	else:
		message_box.text = "You are now in level " + String(Globals.levelNumber)
	points_label.text = "Points: " + String(Globals.points)
	gold_label.text = "Gold: " + String(Globals.gold)

func reaload_level():
	get_tree().reload_current_scene()

func _input(event):
	if(Globals.state == 1):
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
		if event.is_action_pressed("talk"):
			Globals.state = 2
			dialog(npc_dict[player.position])
	if(Globals.state == 2):
		if event.is_action_pressed("dialog_next"):
			if (Globals.dialogPane >= npc_dict[player.position].dialog.dialogPagesNumber):
				Globals.state = 1
				Globals.dialogPane = 0
				dialog_box.hide()
			else: 
				dialog(npc_dict[player.position])
	

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
	if kobold != null && position == kobold.position:
			if npc_dict[player.position].firstMeeting == true:
				message_box.text = "You meet Bobold the Kobold"
				npc_dict[player.position].firstMeeting = false # Think about this later
			if npc_dict[player.position].firstMeeting == false:
				npc_dict[player.position].greeting = "We meet again!"

	if exit != null && position == exit.position:
		if (hasKey):
			Globals.levelNumber += 1
			reaload_level()
		else:
			message_box.text = "The exit is locked!"
func search(cell):
	message_box.text = cell.searched_description
	cell.searched_description = "You searched this cell already"
	if (!cell.isEmpty):
		if (cell.gold != 0):
			Globals.gold += cell.gold
			gold_label.text = "Gold: " + String(Globals.gold)
			cell.isEmpty = true
			cell.gold = 0
func dialog(npc):
	
	dialog_text.text = npc.dialog.dialogText[Globals.dialogPane]

	dialog_box.show()
	Globals.dialogPane = Globals.dialogPane + 1
	npc_dict[player.position].firstMeeting = false
	
	

