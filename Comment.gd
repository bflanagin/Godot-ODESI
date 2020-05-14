extends Control

var OpenSeed
var Thicket 

var data
var author
var post
var postImg

func _ready():
	OpenSeed = get_node("/root/OpenSeed")
	Thicket = get_node("/root/Thicket")
	OpenSeed.connect("comment",self,"comment_returned")

func _on_Close_pressed():
	hide()
	$TextEdit.text = ""

func _on_Send_pressed():
	print($TextEdit.text)
	OpenSeed.openSeedRequest("send_hive_comment",[OpenSeed.token,author,post,$TextEdit.text])
	#if OpenSeed.send_comment() == "Success":
	#	hide()


func _on_Comment_visibility_changed():
	if visible:
		author = data[1]
		post = data[2]
		postImg = data[3]
		#$Bottom/Contact.pImage = postImg
		#$Bottom/Contact.title = post
		$Bottom/Label.text = post
		#$Bottom/Contact.emit_signal("refresh")
	pass # Replace with function body.

func comment_returned(data):
	if data["response"] == "added":
		hide()
	pass
