extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var account = ""
signal view(account)
# Called when the node enters the scene tree for the first time.
func _ready():
	$Contact.emit_signal("refresh")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Contact_info_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		emit_signal("view",account)
	pass # Replace with function body.
