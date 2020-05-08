extends Control
var scores = ""
var OpenSeed
# warning-ignore:unused_signal
signal get_scores(number)

# Called when the node enters the scene tree for the first time.
func _ready():
	OpenSeed = get_node("/root/OpenSeed")
	pass

func update_board():
	for score in scores.split("(b"):
		var name = ""
		var thescore = "N/A"
		if score:
			name = score.split("', '")[0].split("'")[1]
			thescore = parse_json(score.split("', '")[1].split(")")[0])
			var scores_display = $scoreC.duplicate()
			var seperator = $HSeparator.duplicate()
			scores_display.get_node("Name").text = name
			scores_display.get_node("Score").text = thescore["score"]
			$ScrollContainer/VBoxContainer.add_child(scores_display)
			$ScrollContainer/VBoxContainer.add_child(seperator)
	pass

func _on_leaderboard_get_scores(number):
	
	clearBoard()
	scores = OpenSeed.get_leaderboard(number)
	update_board()
	

func _on_Close_Button_pressed():
	self.hide()
	clearBoard()
	
func clearBoard():
	var items = $ScrollContainer/VBoxContainer.get_child_count()
	while items >= 1:
		var kid = $ScrollContainer/VBoxContainer.get_child(items)
		$ScrollContainer/VBoxContainer.remove_child(kid)
		items -=1
