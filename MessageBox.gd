extends Panel

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var message = ""
var date = ""
var speaker = ""
# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/HBoxContainer/date.text = date
	$VBoxContainer/HBoxContainer/name.text = speaker
	$msg.text = message
	set_custom_minimum_size(Vector2(self.rect_size.x,str(message).length() +100))
	#self.set("self_modulate", Color(1,1,1,1))
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#set_custom_minimum_size(Vector2(self.rect_size.x,str(message).length() +100))
	#set_size(Vector2(self.rect_size.x,$VBoxContainer/msg.rect_size.y))
	#self.set("rect_size.y",$VBoxContainer/msg.rect_size.y + 200)
	#self.set("self_modulate", Color(1,1,1,1))
#	pass


func _on_msg_size_flags_changed():
	#set_custom_minimum_size(Vector2(self.rect_size.x,str(message).length() +100))
	#self.rect_size.y = $VBoxContainer/msg.rect_size.y + 200
	#self.self_modulate = Color(1,1,1,1)
	pass # Replace with function body.
