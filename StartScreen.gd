extends Node3D

var _gameStarted = false
var _startLabel: Label
var _player
var _ui

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Engine.time_scale = 1 ## debugging tool for controlling speed of playback

	var ui_scene = load("res://ui.tscn")
	_ui = ui_scene.instantiate()
	add_child(_ui)

	_startLabel = $CanvasLayer/StartLabel
	_startLabel.visible = true
	
	process_mode = Node3D.PROCESS_MODE_ALWAYS
	
	_player = $Player
	
	get_tree().paused = true ## pauses


func _unhandled_input(event: InputEvent) -> void:
	if _gameStarted:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		StartGame()
	elif event is InputEventScreenTouch and event.is_pressed():
		StartGame()

func StartGame():
	_gameStarted = true
	_startLabel.visible = false
	get_tree().paused = false
	$Player.StartRunning()
	$WallGenerator.StartGenerating()
