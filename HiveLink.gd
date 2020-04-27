extends Control
#var OpenSeed = load("res://elements/OpenSeed.gd")
#var openseed = OpenSeed.new()
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var OpenSeed

var imageFile = Image.new()
var textureFile = ImageTexture.new()
var textureList = []

signal linked

# Called when the node enters the scene tree for the first time.
func _ready():
	OpenSeed = get_node("/root/OpenSeed")
	
	pass # Replace with function body.

func _on_Link_pressed():
	OpenSeed.steem = $Username.text
	OpenSeed.saveUserData()
	var redirect = "http://142.93.27.131:8675/steemconnect/verify.py"
	var fulllink = "https://steemconnect.com/oauth2/authorize?client_id=openseed&redirect_uri="+redirect+"&response_type=code&scope=offline,comment,vote,comment_option,custom_json"
	match (OS.get_name()):
		"X11":
			var _pid = OS.execute("x-www-browser",[fulllink],true)
			
	emit_signal("linked")


func _on_Cancel_pressed():
	hide()
	pass # Replace with function body.

func check_name(thename):
	var account = parse_json(OpenSeed.get_steem_account(thename))
	if account and str(account["profile"]).find("Not found") == -1 :
		if str(account["profile"].keys()).find("name") != -1:
			$AccountView/HBoxContainer/VBoxContainer/Name.text = account["profile"]["name"]
		else:
			$AccountView/HBoxContainer/VBoxContainer/Name.text = thename
		if str(account["profile"].keys()).find('about') != -1:	
			$AccountView/HBoxContainer/VBoxContainer/Discription.text = account["profile"]["about"]
		else:
			$AccountView/HBoxContainer/VBoxContainer/Discription.text = "Cloaked in shadows"
		$AccountView/HBoxContainer/Contact.title = thename
		if str(account["profile"].keys()).find('profile_image') != -1:
			$AccountView/HBoxContainer/Contact.pImage = account["profile"]["profile_image"]
		else:
			$AccountView/HBoxContainer/Contact.pImage = "none"
			
		$AccountView/HBoxContainer/Contact.block = imageFile
		$AccountView/HBoxContainer/Contact.texblock = textureFile
		$AccountView/HBoxContainer/Contact.emit_signal("refresh")
		$AnimationPlayer.play("account_found")

func _on_Username_text_entered(new_text):
	print(new_text)
	pass # Replace with function body.

func _on_Username_text_changed(_new_text):
	$text_timeout.start()
	pass # Replace with function body.


func _on_text_timeout_timeout():
	check_name($Username.text)
	
	$text_timeout.stop()
	pass # Replace with function body.
