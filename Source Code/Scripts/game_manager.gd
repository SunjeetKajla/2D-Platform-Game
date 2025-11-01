extends Node

var score = 0

@onready var score_label: Label = $"ScoreLabel"

func add_point():
	score += 1
	score_label.text = "You collected\n" + str(score) + "/10 coins."
	if score==10:
		score_label.text = "You collected\n" + str(score) + "/10 coins.\nCongratulations!!"
