extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var profile = {}
var user = ""
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func load_account(account):
	user = account 
	profile = OpenSeed.get_openseed_account(account)
	print(profile)
	if profile.has("openseed"):
		$Name.text = profile["openseed"]["name"]
	else:
		$Name.text = account

func _on_Accept_pressed():
	OpenSeed.set_request(user,"accept")
	hide()


func _on_Later_pressed():
	hide()


func _on_Reject_pressed():
	OpenSeed.set_request(user,"denied")
	hide()

	

