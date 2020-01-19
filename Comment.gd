extends Control

var OpenSeed
var Thicket 
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	OpenSeed = get_node("/root/OpenSeed")
	Thicket = get_node("/root/Thicket")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Close_pressed():
	hide()
	$TextEdit.text = ""



func _on_Send_pressed():
	if OpenSeed.send_comment() == "Success":
		hide()
	
	pass # Replace with function body.
