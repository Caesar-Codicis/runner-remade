extends Node3D

var _gameStarted = false
var _startLabel: Label
var _player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
