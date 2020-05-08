extends Panel
var OpenSeed 

var username = ""
var steemaccount = ""
var thescore = 0

signal send_score(data)
signal score(num)
signal sent()

# Called when the node enters the scene tree for the first time.
func _ready():
	OpenSeed = get_node("/root/OpenSeed")
	OpenSeed.loadUserData()
	$Player.text = OpenSeed.username
	$Score.text = str(thescore)

# Sending a score to the server is done by emitting the send_score signal
# Given that signal packets are often just one payload we construct and array with a nested array 
# The first member in the array MUST be the players name or some identifier for the player, the second is the data you want to store
# Example: emit_signal("send_score",["bflanagin",['score:200','kills:5']])
# The second array's data must be in the format displayed so that the data is stored in a json friendly format.

func _on_ScoreEntry_send_score(data):
	OpenSeed.update_leaderboard(data[0],data[1])
	self.emit_signal("sent")
	self.hide()

func _on_Button_pressed():
	var score = "score:"+str($Score.text)
	var data = [OpenSeed.username,[score]]
	self.emit_signal("send_score",data)

func _on_ScoreEntry_score(num):
	thescore = num
	$Score.text = str(thescore)

