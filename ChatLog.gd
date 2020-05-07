extends PanelContainer
var chatmessage = preload("res://elements/MessageBox.tscn")

var box 
var offset = 0
var key = ""
var room = ""
var SocialRoot
var currentuser = ""
var OpenSeed
var Thicket
var last = 0

signal change_user(currentuser)

var history_retrieved = false

var chat_history = {}

func _ready():
	OpenSeed = get_node("/root/OpenSeed")
	Thicket = get_node("/root/Thicket")
	OpenSeed.connect("chatdata",self,"update_chat")
	OpenSeed.connect("sent_chat",self,"chatbox_reset")
	OpenSeed.connect("chat_history",self,"fast_chat_update")
	OpenSeed.connect("conversations",self,"_on_conversations_update")
	OpenSeed.connect("keydata",self,"key_recieved")
	box = $VBoxContainer/ScrollContainer/VBoxContainer
	$Timer.start()
	if SocialRoot:
		SocialRoot.connect("changeview",self,"_on_account_view")

func get_key():
	if room != "":
		OpenSeed.get_keys_for(OpenSeed.username+","+currentuser,room)

func _on_Timer_timeout():
	if key != "" and key != "denied":
		#print("from timeout:updating")
		if currentuser and OpenSeed.username != currentuser:
			room = OpenSeed.find_by_attendees([currentuser,OpenSeed.username])
		#	print("from timeout: "+room)
			#print("from timeout: "+key)
			if room != "" and history_retrieved == false :
				#print("getting chat history")
				OpenSeed.openSeedRequest("get_chat_history",[room,10,0])
			else:
				#print("getting chat")
				OpenSeed.openSeedRequest("get_chat",[room,last])
				

func update_chat(data):

	if key != "" and key != "denied":
		var json = data
		if json.has("index") and json["index"] != "-1":
			var decrypted_message = OpenSeed.simp_decrypt(key,json["message"])
			if decrypted_message != "no key":
				box.get_parent().set_v_scroll(box.rect_size.y)
				var newmessage = chatmessage.instance()
				newmessage.date = json["date"]
				newmessage.speaker = json["speaker"]
				newmessage.message = decrypted_message
				box.add_child(newmessage)
				
				last = json["index"]
				
		elif json and json.has("speaker"):
			if json["speaker"] == "server":
					
				match json["message"]:
					"none":
						$Timer.wait_time = 40
	else:
		$Timer.wait_time = 200

func _on_message_text_entered(new_text):
	var returned = ""
	if room != "":
		if key:
			OpenSeed.send_chat(OpenSeed.simp_crypt(key,new_text),room)
			
		else:
			print("no Key")
	else:
		print("no room")


func _on_account_view(account):
	
	if account != OpenSeed.username:
		self.show()
	else:
		self.hide() 	

func chatbox_reset(data):
	
	$VBoxContainer/InputArea/message.text = ""
	if data:
		
		OpenSeed.openSeedRequest("get_chat",[room,last])
	#else:
		#_on_message_text_entered(text)
	pass

func fast_chat_update(data):
	print("from Fast Update")
	var dat = data
	if typeof(dat) == TYPE_ARRAY:
		for line in dat:
			#print(line)
			update_chat(line)
		history_retrieved = true
	pass


func _on_ChatLog_change_user(current):
	currentuser = current
	history_retrieved = false
	chat_history = []
	key = ""
	while box.get_child_count() > 0:
		var thechild = box.get_child(box.get_child_count() -1)
		box.remove_child(thechild)
	
	room = OpenSeed.find_by_attendees([current,OpenSeed.username])
	get_key()
	if room != "" and key != "":
		OpenSeed.openSeedRequest("get_chat_history",[room,10,0])

func from_conversations(data):
	for conv in data:
		if conv["room"] == room:
			pass


func _on_VBoxContainer_resized():
	var the_bottom = box.get_parent().get_child(2).max_value
	box.get_parent().set("vertical_scroll",the_bottom)
	box.get_parent().set_v_scroll(the_bottom)
	pass


func _on_ScrollContainer_scroll_ended():
	print("Scroll position: "+str(box.get_parent().get_v_scroll()))
	
func _on_conversations_update(_data):
	
	for chatroom in OpenSeed.conversations:
		if history_retrieved == true:
			if room == "":
				if chatroom["attendees"] == OpenSeed.username+","+currentuser or chatroom["attendees"] == currentuser+","+OpenSeed.username:
					room = chatroom["room"]
					if int(last) <= int(chatroom["index"]):
						OpenSeed.openSeedRequest("get_chat",[room,last])

					break
			else:
				if chatroom["room"] == room:
					if int(last) <= int(chatroom["index"]):
						OpenSeed.openSeedRequest("get_chat",[room,last])
					break

func key_recieved(data):
	if typeof(data) == TYPE_DICTIONARY and data["room"] == room:
		key = data["key"] 
	
