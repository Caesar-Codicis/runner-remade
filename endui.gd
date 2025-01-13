extends Control

var highScore = 4
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_label_sizes()
	var currentScore = get_node("../Player").score
	
	update_high(currentScore)
	
	set_label_text(highScore,currentScore)

func update_high(n):
	if highScore > n:
		return
	else:
		highScore = n
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func set_label_text(higher,lower):
	var highscoreLabel = $CanvasLayer/Highlabel
	highscoreLabel.text = "Highscore: " + str(higher)
	
	var scoreLabel = $CanvasLayer/Label
	scoreLabel.text = "Score: " + str(lower)

func set_label_sizes():
	$CanvasLayer/ColorRect.size = get_viewport().get_visible_rect().size
