extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var profile
var thetrack 
var OpenSeed 
# warning-ignore:unused_signal
signal download(track)

# Called when the node enters the scene tree for the first time.
func _ready():
	OpenSeed = get_node("/root/OpenSeed")
	$Download/Control/download.text = "Tip"
	pass # Replace with function body.

func _on_steemWallet_visibility_changed():
	OpenSeed.loadUserData()
	if visible and OpenSeed.hive:
		profile = parse_json(OpenSeed.get_full_steem_account(OpenSeed.hive))
		var metadata = parse_json(profile["json_metadata"])
		$hive_amount.text = profile["balance"]
		$hbd_amount.text = profile["hbd_balance"]
		$Name.text = metadata["profile"]["name"]
		$Discription.text = metadata["profile"]["about"]


func _on_cancel_pressed():
	self.hide()
	

func _on_download_pressed():
	$Download/VBoxContainer/Control/download.text = "Sending"
	var dsound_cut = 0
	var openseed_cut = 0
	var price = $Download/VBoxContainer/Control2/payment.value
	var token = $Download/VBoxContainer/Control2/OptionButton.selected
	if price > 0:
		openseed_cut = 0.05/price 
		dsound_cut = 0.05/price
	var payout 
	if price >=0.33 :
		payout = price - openseed_cut - dsound_cut
		OpenSeed.send_tokens([payout,token],thetrack[1],[thetrack[2]])
		OpenSeed.send_tokens([openseed_cut,token],"openseed",[thetrack[1],thetrack[2]])
		OpenSeed.send_tokens([dsound_cut,token],"dsound",[thetrack[1],thetrack[2]])
	elif price > 0:
		payout = price
		OpenSeed.send_tokens([payout,token],thetrack[1],thetrack[2])
	else:
		payout = 0
	hide()

func _on_steemWallet_download(track):
	$Download/VBoxContainer/title.text = track[2]+"\nby: "+track[1]
	thetrack = track
	pass # Replace with function body.


func _on_FileDialog_dir_selected(dir):
	var _fullpath = dir+thetrack[2]+" "+thetrack[1]
	pass # Replace with function body.

