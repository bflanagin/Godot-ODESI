extends Control
var OpenSeed
var username = ""
var passphrase = ""
var newtoken = ""
signal login(status)

func _ready():
	OpenSeed = get_node("/root/OpenSeed")
	OpenSeed.connect("accountdata",self,"verify_account")

func _on_Username_text_changed(new_text):
	username = new_text

func _on_Passphrase_text_changed(new_text):
	passphrase = new_text

func _on_Okay_pressed():
	print("sending request to verify")
	OpenSeed.openSeedRequest("verify_account",[username,passphrase])

func verify_account(data):
	if typeof(data) == TYPE_DICTIONARY:
		match data["token"]:
			'denied':
				$notification.text = "Incorrect username/password"
			'none':
				$notification.text = "No User Found"
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


func _on_NewAccount_pressed():
	get_parent().get_node("NewAccount/Username").text = username
	get_parent().get_node("NewAccount/Passphrase").text = passphrase
	get_parent().get_node("NewAccount").visible = true
	self.hide()



func _on_HiveAccount_pressed():
	pass # Replace with function body.


func _on_PrivateKey_text_entered(new_text):
	pass # Replace with function body.


func _on_PrivateKey_text_changed(new_text):
	pass # Replace with function body.


func _on_Cancel_pressed():
	self.hide()
	OpenSeed.get_node("CanvasLayer/Login").show()
	pass # Replace with function body.
