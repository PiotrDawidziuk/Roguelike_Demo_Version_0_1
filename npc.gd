extends Node

class NPC:
	var position
	var firstMeeting = true
	var greeting = "Hello"
	var dialogPanelsNumber = 1
	var dialog
	var instance

class Dialog:
	var dialogPagesNumber = 1
	var dialogText = {}
	
