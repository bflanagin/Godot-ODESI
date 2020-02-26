extends Control

var OpenSeed
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var username = ""
var passphrase = ""
var newtoken = ""
signal login(status)
# Called when the node enters the scene tree for the first time.
func _ready():
	OpenSeed = get_node("/root/OpenSeed")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Username_text_changed(new_text):
	username = new_text

func _on_Passphrase_text_changed(new_text):
	passphrase = new_text

func _on_New_pressed():
	get_parent().get_node("NewAccount/Username").text = username
	get_parent().get_node("NewAccount/Passphrase").text = passphrase
	get_parent().get_node("NewAccount").visible = true
	self.hide()

func _on_Okay_pressed():
	var response = OpenSeed.verify_account(username,passphrase)
	print(response)
	match response:
		'{"user":"denied"}':
			$notification.text = response
		'{"user":"none"}':
			$notification.text = "No User Found"
		_:
			$notification.text = "granted" 
			emit_signal("login",1)
			if len(OpenSeed.token) < 2:
				OpenSeed.token = parse_json(response)["user"]
			OpenSeed.username = username
			OpenSeed.saveUserData()
			self.hide()
			
	pass # Replace with function body.

