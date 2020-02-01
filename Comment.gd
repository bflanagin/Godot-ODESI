extends Control

var OpenSeed
var Thicket 

func _ready():
	OpenSeed = get_node("/root/OpenSeed")
	Thicket = get_node("/root/Thicket")

func _on_Close_pressed():
	hide()
	$TextEdit.text = ""

func _on_Send_pressed():
	if OpenSeed.send_comment() == "Success":
		hide()
