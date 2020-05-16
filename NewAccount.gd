extends Control

var OpenSeed 

var username = ""
var passphrase = ""
var email = ""

signal login(status)
# Called when the node enters the scene tree for the first time.
func _ready():
	OpenSeed = get_node("/root/OpenSeed")
	OpenSeed.connect("accountdata",self,"verify_account")
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
		OpenSeed.openSeedRequest("create_account",[username,passphrase,email])
		
	else:
		$notification.text = "Please fill in all fields"
	pass # Replace with function body.


func _on_Cancel_pressed():
		self.hide()
		OpenSeed.get_node("CanvasLayer/Login").show()


func verify_account(data):
	if typeof(data) == TYPE_DICTIONARY:
		match data["token"]:
			'denied':
				$notification.text = "User Exists"
				#emit_signal("login",0)
			_:
				$notification.text = "granted" 
				emit_signal("login",1)
				if len(OpenSeed.token) < 2:
					OpenSeed.token = data["token"]
					print(OpenSeed.token)
				OpenSeed.username = username
				OpenSeed.steem = ""
				OpenSeed.saveUserData()
				self.hide()

func _on_NewAccount_visibility_changed():
	pass # Replace with function body.
