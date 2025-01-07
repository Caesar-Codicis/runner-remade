extends Control

var scoreLabel
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scoreLabel = $CanvasLayer/Label
	scoreLabel.text = "Score: 0"

func updateScore(score):
	scoreLabel.text = "Score: " + str(score)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
