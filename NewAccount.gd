extends Control

var openseed 

var username = ""
var passphrase = ""
var email = ""

signal login(status)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Username_text_changed(new_text):
	username = new_text

func _on_Email_text_changed(new_text):
	email = new_text

func _on_Passphrase_text_changed(new_text):
	passphrase = new_text 

func _on_Create_pressed():
	if username and passphrase and email:
		var response = openseed.create_user(username,passphrase,email)
		match response:
			_:
				emit_signal("login",2)
				openseed.token = response.split("\n")[0]
				openseed.username = username
				#get_parent().get_node("Login/Username").text = username
				#get_parent().get_node("Login/Passphrase").text = passphrase
				#get_parent().get_node("Login/notification").text = "Press Okay to Continue"
				#get_parent().get_node("Login").show()
				openseed.saveUserData()
				get_parent().get_node("SteemLink").show()
				hide()
	else:
		$notification.text = "Please fill in all fields"
	pass # Replace with function body.


func _on_Cancel_pressed():
		self.hide()



func _on_NewAccount_visibility_changed():
	if visible:
		openseed = get_parent().get_parent().get_node("OpenSeed")
	
	pass # Replace with function body.
