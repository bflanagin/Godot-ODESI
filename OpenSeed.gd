extends Node

# Setup variables 
var thread = Thread.new()
var imgfile = File.new()
var Imagedata = Image.new()
var noimage = preload("res://Img/folder-music-symbolic.svg")

var username = ""
# warning-ignore:unused_class_variable
var passphrase = ""
# warning-ignore:unused_class_variable
var email = ""
var token = ""
var steem = ""
# warning-ignore:unused_class_variable
var postingkey = ""
# warning-ignore:unused_class_variable
var steem_node = ""
# warning-ignore:unused_class_variable
var devPub = ""
var devId = ""
# warning-ignore:unused_class_variable
var appPub = ""
var appId = ""
var openseed = "openseed.solutions"
var version = ""
var ipfs = ""
var connection = ""
# warning-ignore:unused_class_variable
var output = ""
var online = true
#var mode = "socket"
#var mode = "web"
var mode = "websocket"
var keys = []
var waiting = false
export var debug = true

#var threadedServer = StreamPeerTCP.new()
#var threadedServerInternal = StreamPeerTCP.new()
#Profile variables
var profile_name = "User"
var profile_email = "User@mail.com"
var profile_about = "Does things and stuff"
var profile_phone = ""
var profile_image = ""
var profile_creator = false
var profile_owns = [] 
var profile_creator_Id = ""
var profile_creator_Pub = ""
var conversations = []

var chatlog = []

# Image store. This is used to access any images that come from OpenSeed itself
# We use a standard dictionary where the image name is the key and the texture is the value. 
# We will have functions to set and retrieve image data.

var image_store = {}
var playlist = []
var retrieved = "newartists"

var send_queue = []
#signals
# warning-ignore:unused_signal
signal login(status)
# warning-ignore:unused_signal
signal interface(type,data)
# warning-ignore:unused_signal
#signal command(type,data)
# warning-ignore:unused_signal
signal linked()
signal userLoaded()

# warning-ignore:unused_signal
signal comment(info)

signal socket_returns(data)

signal accountdata(data)
signal profiledata(data)
signal chatdata(data)
signal sent_chat(data)
signal chat_history(data)
signal new_chat()
signal keydata(data)
signal conversations(data)
signal connections(data)
signal user_status(data)
signal request_status(data)
signal ChatMessageRecieved(data)

signal tracks(data)
signal genres(data)
signal artists(data)

signal new_tracks(data)
signal new_artists(data)

# warning-ignore:unused_signal
signal queue_updated(data)
signal historydata(data)
# warning-ignore:unused_signal
signal imagestored(data)
signal image_data(data)

# warning-ignore:unused_signal
signal update_loop(last)

var dev_steem = ""
var dev_postingkey = ""
var appdefaults 

var threadedServer = StreamPeerTCP.new()
var server = StreamPeerTCP.new()
var websocket = WebSocketClient.new()

export var retry = 15
var retried = 0

# Called when the node enters the scene tree for the first time.
# Default mode is set to login for obvious reasons. 
# Current interface options include:
# login: typical login interface also includes the new account creation dialogs
# steem: Interface to allow users to connect their game to the steem blockchain for cloud services.

func _ready():
	appdefaults = '"appPub":"'+str(appPub)+'","devPub":"'+str(devPub)+'"'
	
	if mode == "websocket":
		print("connecting websocket signals")
		websocket.connect("connection_closed", self, "_closed")
		websocket.connect("connection_error", self, "_closed")
		websocket.connect("connection_established", self, "_connected")
		# This signal is emitted when not using the Multiplayer API every time
		# a full packet is received.
		# Alternatively, you could check get_peer(1).get_available_packets() in a loop.
		websocket.connect("data_received", self, "_on_data")
		# Initiate connection to the given URL.
		var err = websocket.connect_to_url("ws://"+openseed+":8765")
		if err != OK:
			print("Unable to connect")
			set_process(false)
	#if mode == "socket":
		

	# warning-ignore:return_value_discarded
	$Timer.connect("timeout",self,"update_loop")
	$Timer.start()

func update_loop():
			
	if OpenSeed.token:
		if send_queue.size() > 0:
			openSeedRequest("queue",[])
			waiting = true
		else:
			openSeedRequest("getConversations",[])
			waiting = true
	else:
		if send_queue.size() > 0:
			openSeedRequest("queue",[])
			waiting = true
				
func send(data,priority):
	var checked = parse_json(data)
	if typeof(checked) == TYPE_DICTIONARY: 
		match priority:
			1:
				if send_queue.find(str(data)) == -1:
					if send_queue.size() >= 1:
						send_queue.insert(0,data)
					else:
						send_queue.append(data)
			2:
				if send_queue.find(str(data)) == -1:
					if send_queue.size() >= 1:
						send_queue.insert(1,data)
					else:
						send_queue.append(data)
			3:
				if send_queue.find(str(data)) == -1:
					if send_queue.size() >= 2:
						send_queue.insert(2,data)
					else:
						send_queue.append(data)
			6:
				if send_queue.find(str(data)) == -1:
					send_queue.push_back(data)
			_:
				if send_queue.find(str(data)) == -1:
					send_queue.append(data)
	else:
		print("json error")
	return 1

func openSeedRequest(type,data):
	appdefaults = '"appPub":"'+str(appPub)+'","devPub":"'+str(devPub)+'"'
	match type:
		
		# Verifies the login creditials of an account on Openseed and reports back pass/fail/nouser.
		"verify_account":
			send('{"act":"account_check",'+appdefaults+',"account":"'+data[0]+'","passphrase":"'+data[1]+'"}',2)
			
		# Creates user based on the provided information. This user is added to the Openseed service. 
		"create_user":
			send('{"act":"create_account",'+appdefaults+',"account":"'+data[0]+'","passphrase":"'+data[1]+'","email":"'+data[2]+'" }',2)
			
		"loadUser":
			loadUserData()
			
		"getProfile":
			send('{"act":"get_profile",'+appdefaults+',"account":"'+data[0]+'"}',2)
			
		"loadProfile":
			loadUserProfile(data[0])
			
		"history":
			if OpenSeed.token != "" and data[0] != "":
				send('{"act":"get_history",'+appdefaults+',"account":"'+data[0]+'","apprange":"'+data[1]+'","count":"'+data[2]+'"}',3)
				
		"get_image":
			send('{'+appdefaults+',"act":"get_image","image":"'+data[0]+'","thetype":"url","quality":"'+data[1]+'"}',3)
			
				
		"updateStatus":
			if OpenSeed.token != "":
				send('{"act":"set_status",'+appdefaults+',"token":"'+OpenSeed.token+'","status":'+data[0]+'}',2)
				
		"getStatus":
			if OpenSeed.token != "" and data[0] != "":
				send('{"act":"get_status",'+appdefaults+',"account":"'+data[0]+'"}',6)
				
		###################
		#
		# Social Functions
		#
		###################
				
		"getRequests":
			if !thread.is_active():
				print("getting Requests")
				
		"get_key":
			send('{"act":"get_key",'+appdefaults+',"thetype":"1","room":"'+data[1]+'","users":"'+data[0]+'","token":"'+OpenSeed.token+'"}',2)
			
		"get_room_by_attendees":
			send('{"act":"find_room_by_attendees",'+appdefaults+',"token":"'+OpenSeed.token+'","attendees":"'+str(data)+'","create":"1"}',2)
			
		"get_chat_history":
			send('{"act":"get_chat_history",'+appdefaults+',"token":"'+OpenSeed.token+'","room":"'+data[0]+'","count":"'+str(data[1])+'","last":"'+str(data[2])+'"}',2)
			
		"get_chat":
			if data[0]:
				send('{"act":"get_chat",'+appdefaults+',"token":"'+OpenSeed.token+'","room":"'+data[0]+'","last":"'+str(data[1])+'"}',2)
				
		"getConversations":
			send('{"act":"get_conversations",'+appdefaults+',"token":"'+OpenSeed.token+'"}',3)
			
		"get_connections":
			if data[0] != "":
				send('{"act":"get_connections",'+appdefaults+',"account":"'+data[0]+'","hive":false}',4)
				
		##################
		#
		# Music functions
		#
		##################
		
		"get_genres":
			send('{"act":"get_genres",'+appdefaults+'}',6)
			
		"get_genre":
			send('{"act":"get_genre",'+appdefaults+',"genre":"'+data[0]+'","count":"50"}',6)
			
		"get_new_tracks":
			send('{"act":"get_new_tracks",'+appdefaults+'}',6)
			
		"get_new_musicians":
			send('{"act":"get_new_musicians",'+appdefaults+'}',6)
			
		
		####################
		#
		# Hive Functions
		#
		####################
		
		"get_hive_account":
			send('{"act":"get_hive_account",'+appdefaults+',"account":"'+data[0]+'"}',3)
			
		"get_hive_post":
			send('{"act":"get_hive_post",'+appdefaults+',"author":"'+data[0]+'","permlink":"'+data[1]+'"}',4)
		
		"set_hive_follow":
			send('{"act":"follow",'+appdefaults+',"hiveaccount":"'+data[0]+'","follow":"'+data[1]+'"}',4)
			
		"send_hive_tokens":
			send('{"act":"payment",'+appdefaults+',"hiveaccount":"'+data[0]+'","amount":"'+data[1]+'","to":"'+data[2]+'","for":"'+data[3]+'"}',4)
			
		"send_hive_like":
			send('{"act":"like",'+appdefaults+',"hiveaccount":"'+data[0]+'","post":"'+data[1]+'"}',2)
			
		"send_hive_comment":
			send('{"act":"comment",'+appdefaults+',"account":"'+data[0]+'","comment":"'+data[1]+'","post":"'+data[2]+'"}',2)
			
		"queue":
			if mode == "socket":
				if !thread.is_active():
					#var msg = send_queue[0]
					var msg = "msg="+appPub+"<::>"+simp_crypt(appId,send_queue[0])+"<::>"
					thread.start(OpenSeed,"get_from_socket_threaded",[msg,"queued_event"])
					
			if mode == "web":
				#var msg = "msg="+appPub+"<::>"+simp_crypt(appId,send_queue[0])+"<::>"
				var msg = "msg="+appPub+"<::>"+send_queue[0]+"<::>"
				#var msg = "msg="+send_queue[0]
				var headers = []
				#$HTTPRequest.connect("request_completed",self,"")
				if waiting == false:
					$HTTPRequest.request("http://api.openseed.solutions/",headers,false,HTTPClient.METHOD_POST,msg)
					waiting = true
				
				#thread.start(OpenSeed,"get_from_socket_threaded",[msg,"queued_event"])
				
				pass
			if mode == "websocket":
				#var msg = "msg="+send_queue[0]
				var msg = "msg="+appPub+"<::>"+simp_crypt(appId,send_queue[0])+"<::>"
				get_from_websocket(msg)
				pass
				
				
func get_from_websocket(data):
	#print("using websocket")
	
	if websocket.get_connection_status() == 0:
		var err = websocket.connect_to_url("ws://"+openseed+":8765")
		if err != OK:
			print("Unable to connect")
			#set_process(false)
		#else:
			#websocket.set_buffers()
			#websocket.get_peer(1).put_packet(data.to_utf8())
			#return(websocket.get_peer(1).get_packet().get_string_from_utf8())
	elif websocket.get_connection_status() == 2:
		websocket.get_peer(1).put_packet(data.to_utf8())
		#return(websocket.get_peer(1).get_packet().get_string_from_utf8())
		
	#print(data)
	
	var fullreturn = ""
	var _timeout = 18000
	
	return fullreturn
	
func _closed(was_clean = false):
	# was_clean will tell you if the disconnection was correctly notified
	# by the remote peer before closing the socket.
	print("Closed, clean: ", was_clean)
	#set_process(false)


func _connected(proto = ""):
	# This is called on connection, "proto" will be the selected WebSocket
	# sub-protocol (which is optional)
	print("Connected with protocol: ", proto)
	# You MUST always use get_peer(1).put_packet to send data to server,
	# and not put_packet directly when not using the MultiplayerAPI.
	#websocket.get_peer(1).put_packet("Test packet".to_utf8())


func _on_data():
	# Print the received packet, you MUST always use get_peer(1).get_packet
	# to receive data from server, and not get_packet directly when not
	# using the MultiplayerAPI.
	var returns = websocket.get_peer(1).get_packet().get_string_from_utf8()
	var decrypt = simp_decrypt(appId,returns).strip_edges()
	_on_OpenSeed_socket_returns(["queue",decrypt])
	#print("Got data from server: "+decrypt) 


func _process(_delta):
	# Call this in _process or _physics_process. Data transfer, and signals
	# emission will only happen when calling this function.
	websocket.poll()


func _exit_tree():
	websocket.disconnect_from_host()
	
						
func get_from_socket_threaded(data):
# warning-ignore:unused_variable
	var fullreturn = ""
	var _timeout = 18000
	var BUFF_SIZE = 4096
	var therest = ""
	if !threadedServer.is_connected_to_host(): 
		threadedServer.connect_to_host(openseed, 8688)
		while threadedServer.get_status() != 2:
			_timeout -= 1
	if threadedServer.is_connected_to_host():
		if threadedServer.get_status() == 2 :
			threadedServer.put_data(data[0].to_utf8())
			
			var fromserver = threadedServer.get_partial_data(BUFF_SIZE)
			var size = threadedServer.get_available_bytes()
			if size > 0:
				if size < BUFF_SIZE:
					therest = threadedServer.get_partial_data(size)[1].get_string_from_utf8()
				else:
					var whatsleft = size
					while whatsleft > BUFF_SIZE:
						therest += threadedServer.get_partial_data(BUFF_SIZE)[1].get_string_from_utf8()
						whatsleft -= BUFF_SIZE
					if whatsleft > 0:
						therest += threadedServer.get_partial_data(whatsleft)[1].get_string_from_utf8()
						
				fullreturn = fromserver[1].get_string_from_utf8() + therest
			else:
				fullreturn = fromserver[1].get_string_from_utf8()
		#print(fullreturn)
		var decrypt = simp_decrypt(appId,fullreturn).strip_edges()
		#var decrypt = fullreturn
		if len(decrypt) >= 0:
			call_deferred("returned_from_socket",data[1])
		if decrypt[-1] != "}":
			print("Incomplete return")
			#print(decrypt)
			return '{"server":"incomplete return error"}'
		else:
			return (decrypt)
		
func returned_from_socket(type):
	print(type)
	var socket = thread.wait_to_finish()
	
	emit_signal("socket_returns",[type,socket])
	
func _on_OpenSeed_socket_returns(data):
	var jsoned 
	if data[1]:
		jsoned = parse_json(data[1])
		if typeof(jsoned) == TYPE_DICTIONARY:
			if jsoned.has("profile"):
				if debug == true:
					retried = 0
					print("finished "+send_queue[0])
				if OpenSeed.profile_name == "":
					saveUserProfile(data[1])
				else:
					emit_signal("profiledata",[jsoned["profile"]["username"],jsoned["profile"]])
			
			if jsoned.has("account"):
				retried = 0
				if debug == true:
					print("finished "+send_queue[0])
				emit_signal("accountdata",jsoned["account"])
				
			if jsoned.has("hive"):
				retried = 0
				if debug == true:
					print("finished "+send_queue[0])
				if jsoned["hive"].has("profile"):
					emit_signal("profiledata",[jsoned["username"],jsoned["hive"]])
				if jsoned["hive"].has("app"):
					emit_signal("profiledata",[jsoned["username"],jsoned["hive"]["app"]])
					
			if jsoned.has("history"):
				retried = 0
				if debug == true:
					print("finished "+send_queue[0])
				emit_signal("historydata",jsoned["history"])
					
					
			if jsoned.has("image"):
				retried = 0
				if debug == true:
					print("finished "+send_queue[0])
				emit_signal("image_data",jsoned["image"])
				add_to_image_store(jsoned["image"]["source"],jsoned["image"]["quality"],jsoned["image"]["hash"])
					
				########
				#
				# Chat
				#
				########
						
			if jsoned.has("chat"):
				retried = 0
				if debug == true:
					print("finished "+send_queue[0])
				emit_signal("chatdata",jsoned["chat"])
						
			if jsoned.has("chat_history"):
				retried = 0
				if debug == true:
					print("finished "+send_queue[0])
				emit_signal("chat_history",jsoned["chat_history"])
			
			if jsoned.has("chat_response"):
				retried = 0
				if debug == true:
					print("finished "+send_queue[0])
				emit_signal("sent_chat",data[1])
						
			if jsoned.has("conversations"):
				retried = 0
				if debug == true:
					print("finished "+send_queue[0])
				if str(conversations) != str(jsoned["conversations"]):
					emit_signal("new_chat")
					conversations = jsoned["conversations"]
					emit_signal("conversations",conversations)
					
			if jsoned.has("lock"):
				retried = 0
				if debug == true:
					print("finished "+send_queue[0])
				emit_signal("keydata",jsoned["lock"])
						
				########
				#
				# Music
				#
				########
				
			if jsoned.has("newtracks"):
				retried = 0
				if debug == true:
					print("finished "+send_queue[0])
				emit_signal("new_tracks",jsoned["newtracks"])
						
			if jsoned.has("new_musicians"):
				retried = 0
				if debug == true:
					print("finished "+send_queue[0])
				emit_signal("new_artists",jsoned["new_musicians"])
					
			if jsoned.has("genre_tracks"):
				retried = 0
				if debug == true:
					print("finished "+send_queue[0])
				emit_signal("tracks",jsoned["genre_tracks"])
					
			if jsoned.has("genres"):
				retried = 0
				if debug == true:
					print("finished "+send_queue[0])
				emit_signal("genres",jsoned["genres"])
						
				########
				#
				# Social
				#
				########
				
			if jsoned.has("status"):
				retried = 0
				if debug == true:
					print("finished "+send_queue[0])
				emit_signal("user_status",[jsoned["status"]["data"]["chat"],jsoned["status"]["account"]])
						
			if jsoned.has("request"):
				retried = 0
				if debug == true:
					print("finished "+send_queue[0])
				emit_signal("request_status",[jsoned["request"],jsoned["account"]])
					
			if jsoned.has("connections"):
				retried = 0
				if debug == true:
					print("finished "+send_queue[0])
				emit_signal("connections",jsoned["connections"])
				
			if jsoned.has("server"):
				retried += 1
				print("error in " + send_queue[0])
				if debug == true:
					print("error in " + send_queue[0])
					print(retried)
			else:
				#if debug == true:
					#print("removing "+send_queue[0])
				send_queue.remove(0)
				
		if retried >= retry:
			retried = 0
			if debug == true:
				print("failed at "+send_queue[0])
				print("got "+data[1])
			send_queue.remove(0)
				
func _on_link_linked():
	
	pass # Replace with function body.

# In this function we send OpenSeed a request to add new data to the leaderboard. Taking two variables u for user and d for the data.
# The data is then reformated into a transmitable json like format for get_leaderboard to parse.
# Note the need for a steem account (called steem) and a postingkey. As a developer you have the choice to use your own postingKey or require the user to use theirs. 
# a small fee 0.001 STEEM is required to post the memo on openseeds account to store the information on the chain. 

#func update_leaderboard(u,d):
#	appdefaults = '"appPub":"'+str(appPub)+'","devPub":"'+str(devPub)+'"'
#	var dataformat = '{\\"'
#	var datapoint = 0
#	while datapoint < len(d):
#		var repoint = d[datapoint].split(":")[0]+'\\":\\"'+d[datapoint].split(":")[1]
#		dataformat = str(dataformat)+str(repoint)
#		if datapoint+1 < len(d):
#			dataformat = str(dataformat)+'\\",\\"'
#		datapoint += 1
#	dataformat = dataformat+'\\"}'
#	var response = get_from_socket('{"act":"toleaderboard",'+appdefaults+',"username":"'+str(u)+'","data":"'+str(dataformat)+'","steem":"'+str(dev_steem)+'","postingkey":"'+str(dev_postingkey)+'"}')
#	return response
	
# warning-ignore:unused_argument
#func get_leaderboard(number):
#	var scores = get_from_socket('{"act":"getleaderboard",'+appdefaults+'}')
#	return scores
	
func set_history(action_type,action):
	var act = ""
	var act_type = ""
	var data = ""
	var format = ""
	match action_type:
		"program_start":
			act_type = 1
			format = action
			data ='{"'+action_type+'":"'+format+'"}'
		"program_stop":
			act_type = 2
		"playing":
			act_type = 3
			if typeof(action) == TYPE_ARRAY:
				format = '{"song":"'+action[0]+'","artist":"'+action[1]+'"}'
				data ='{"'+action_type+'":'+format+'}'
			else:
				format = ""
		"purchase":
			act_type = 4
			format = action
			data ='{"'+action_type+'":"'+format+'"}'
		"download":
			act_type = 5
			format = action
			data ='{"'+action_type+'":"'+format+'"}'
		"linked":
			act_type = 6
			format = action
			data ='{"'+action_type+'":"'+format+'"}'
		_:
			act_type = 0
			format = action
			data ='{"'+action_type+'":"'+format+'"}'
			
	var packet = '"act":"update_history",'+appdefaults+',"type":"'+str(act_type)+'","account":"'+str(OpenSeed.token)+'"'
	if format != "":
		send('{'+packet+',"data":'+str(data)+'}',5)
		
func saveUserData():
	var file = File.new()
	var key = appId+devId+str(123456)
	var content = '{"usertoken":"'+str(token)+'","username":"'+str(username)+'","steemaccount":"'+str(steem)+'","postingkey":"'+str(postingkey)+'"}'
	file.open_encrypted_with_pass("user://openseed.dat", File.WRITE,key)
	file.store_string(content)
	file.close()
	
func saveUserProfile(data):
	var file = File.new()
	file.open("user://"+username+"profile.dat",File.WRITE)
	file.store_string(data)
	file.close()
	
func loadUserProfile(account):
	appdefaults = '"appPub":"'+str(appPub)+'","devPub":"'+str(devPub)+'"'
	var file = File.new()
	var profile
	if file.file_exists("user://"+account+"profile.dat"):
		file.open("user://"+account+"profile.dat",File.READ)
		var content = parse_json(file.get_as_text())["profile"]
		if content:
			profile_name = content["openseed"]["name"]
			profile_about = content["extended"]["about"]
			if content["extended"].has("profile_img"):
				profile_image = content["extended"]["profile_img"]
			else:
				profile_image = ""
			profile_email = content["openseed"]["email"]
			profile_phone = content["openseed"]["phone"]
			emit_signal("userLoaded")
		else:
			print("no profile found")
			if !thread.is_active():
				openSeedRequest("getProfile",[account])
				#emit_signal("socket_returns",["profile",profile])
		file.close()
	else:
		print("no profile found")
		if !thread.is_active():
			openSeedRequest("getProfile",[account])
			#emit_signal("socket_returns",["profile",profile])
			
	return profile_name
	
func loadUserData():
	var file = File.new()
	var key = appId+devId+str(123456)
	file.open_encrypted_with_pass("user://openseed.dat", File.READ,key)
	var content = parse_json(file.get_as_text())
	
	file.close()
	if content:
		username = content["username"]
		token = content["usertoken"]
		steem = content["steemaccount"]
		postingkey = content["postingkey"]
		openSeedRequest("updateStatus",['{"chat":"Online"}'])
		emit_signal("userLoaded")
		
	return content

func check_ipfs():
	var ipfs_output = []
	var ipfs_path = ""
	var file = File.new()
	if OS.get_name() == "X11":
		if file.file_exists("/usr/bin/ipfs"):
			ipfs_path = "/usr/bin/ipfs"
		elif file.file_exists("/snap/bin/ipfs"):
			ipfs_path = "/snap/bin/ipfs"
		if ipfs_path != "":
			ipfs = ipfs_path
# warning-ignore:return_value_discarded
			OS.execute("ps",["-e"],true,ipfs_output)
			print(ipfs_output[0].find("ipfs"))
			if ipfs_output[0].find("ipfs") == -1:
				print(OS.execute(ipfs_path,["daemon","--routing=dhtclient"],false))
				
###########################################################################
#
# Social Functions (Profiles, Requests, Connections, etc,)
#
###########################################################################
	
func get_openseed_account(account):
	appdefaults = '"appPub":"'+str(appPub)+'","devPub":"'+str(devPub)+'"'
	openSeedRequest("getProfile",[account])
	
func get_openseed_account_status(account):
	appdefaults = '"appPub":"'+str(appPub)+'","devPub":"'+str(devPub)+'"'
	var status = '{"act":"get_status",'+appdefaults+',"account":"'+account+'"}'
	send(status,6)
	
###########################################################################
#
# Chat Functions 
#
###########################################################################

func create_chatroom(title,attendees):
	var command = '{"act":"create_chatroom","appPub":"'+str(appPub)+'","devPub":"'+str(devPub)+ \
					'","token":"'+OpenSeed.token+'","title":"'+str(title)+'","attendees":"'+attendees+'"}'
	send(command,3)

#func find_room_by_attendess(attendees):
#	var command = parse_json(get_from_socket('{"act":"find_room_by_attendees","appPub":"'+str(appPub)+'","devPub":"'+str(devPub)+ \
#					'","token":"'+OpenSeed.token+'","attendees":"'+attendees+'","create":"1"}'))
#	return command
	
# warning-ignore:shadowed_variable
func send_chat(message,room):
	var command = '{"act":"send_chat","appPub":"'+str(appPub)+'","devPub":"'+str(devPub)+ \
					'","token":"'+OpenSeed.token+'","room":"'+str(room)+'","message":"'+message+'"}' 
	if send_queue.find(str(command)) == -1:
		send(command,1)
	return "queued"
				

##############################################################################
#
# Connection functions
#
#############################################################################
	
# warning-ignore:unused_argument
func send_request(account,response):
	var command = '{"act":"send_request","appPub":"'+ \
					str(appPub)+'","devPub":"'+str(devPub)+ \
					'","token":"'+OpenSeed.token+'","account":"'+account+'"}'
	send(command,5)

func set_request(account,response):
	var command = '{"act":"set_request","appPub":"'+ \
					str(appPub)+'","devPub":"'+str(devPub)+ \
					'","token":"'+OpenSeed.token+'","account":"'+account+'","response":"'+response+'"}'
	send(command,1)

func get_request_status(account):
	var command = '{"act":"get_request_status","appPub":"'+str(appPub)+'","devPub":"'+str(devPub)+ \
					'","token":"'+OpenSeed.token+'","account":"'+account+'"}'
	send(command,6)

	
func find_by_attendees(attendees):
	var room = ""
	for convo in conversations:
		var list = convo["attendees"].split(",")
		for person in attendees:
			var indx = 0
			for p in list:
				if p == person:
					list.remove(indx)
				indx += 1
		if list.size() == 0:
			room = convo["room"]
			break
	return room
##################################################
#
# Encryption Functions
#
##################################################
	
func get_keys_for(users,room):
	var key = ""
	for test in keys:
		if test["room"] == room:
			key = test["key"]
			break
	if key == "":
		appdefaults = '"appPub":"'+str(appPub)+'","devPub":"'+str(devPub)+'"'
		openSeedRequest("get_key",[users,room])
	else:
		emit_signal("keydata",{"key":key,"room":room})
	return key

func simp_crypt(key,raw_data):
	
	if debug == true:
		#print("encrypting "+raw_data)
		#print("using "+key)
		pass
		
	var num_array = []
	for c in key:
		if int(c) and int(c) % 2 == 0:
			num_array.append(c)
			
	while len(num_array) <= len(raw_data):
		num_array += num_array		
	num_array += num_array
	
	var secret = ""
	var datanum = 0
	var digits = ""
	var key_digits = ""
	var key_stretch = key
	var keystring = "" 

	#//lets turn it into integers first//
	for t in raw_data.replace("%", ":percent:").replace("&", ":ampersand:"):
		var c = t.ord_at(0)
		digits += str(c)+" "
		
	var data = digits
	
	if key_stretch != "":
		if len(data)> len(key_stretch):
			while len(key_stretch) < len(data):
				key_stretch = key_stretch + key
				
	key_stretch = key_stretch.substr(0,len(data))
	
	data = data.split(" ")
	
	for b in key_stretch:
		var i = b.ord_at(0)
		key_digits += str(i)+" "
	key_digits = key_digits.split(" ")	

	var keynum = 0

	for d in data:
		if d:
			if int(d) == int(key_digits[keynum]):
				secret += char(int(d))
			else:
				var combine = 0
				if int(num_array[keynum]) % 2 == 0:
					combine = int(d) + int(key_digits[keynum])
				else:
					combine =int(d) * int(num_array[keynum]) 
					
				secret = secret + char(combine)
		keynum += 1
		
	if debug == true:
		#print("encrypted as "+secret.replace(" ","zZz"))
		pass
		
	return secret.replace(" ","zZz").strip_edges()

func simp_decrypt(key,raw_data):
	
	if debug == true:
		#print("decrypting "+raw_data)
		#print("using "+key)
		pass
		
	if key == "":
		print("no key")
		return
		
	var num_array = []
	for c in key:
		if int(c) and int(c) % 2 == 0:
			num_array.append(c)
			
	while len(num_array) <= len(raw_data):
		num_array += num_array
	num_array += num_array	
	
	if debug == true:
		#print("num array: ",num_array)
		pass
		
	var key_stretch = key
	var message = ""
	var datanum = 0
	var decoded = ""
	var key_digits = ""
	var digits = ""
	
	for t in raw_data.replace("zZz"," "):
		var c = t.ord_at(0)
		digits += str(c)+" "
		
	var data = digits
	
	if key_stretch != "":
		if len(data)> len(key_stretch):
			while len(key_stretch) < len(data):
				key_stretch = key_stretch + key
				
	key_stretch = key_stretch.substr(0,len(data))
	
	if debug == true:
		#print("Key stretched to "+ key_stretch)
		pass
		
	data = data.split(" ")
	
	if debug == true:
		#print("data in digits ",data)
		pass
	
	for b in key_stretch:
		var i = b.ord_at(0)
		key_digits += str(i)+" "
	
	key_digits = key_digits.split(" ")
	
	if debug == true:
		#print("key in digits ",key_digits)
		pass
	#message = raw_data
	var keynum = 0
	for d in data:
		var test1 = 0
		var test1a = 0
		var test2 = 0
		
		if d:
			if int(d) == int(key_digits[keynum]):
				message += char(int(d))
			else:
				var combine = 0
				if int(num_array[keynum]) % 2 == 0:
					combine = int(d) - int(key_digits[keynum])
				else:
					combine =int(d) / int(num_array[keynum]) 
				message += char(combine)

		keynum += 1
	return message.strip_edges()
	
	
##########################################
#
# OpenSeed UI
#
##########################################

func interface(type,show,data):
	match type :
		"login":
			$CanvasLayer/Login.visible = show
			
			$CanvasLayer/NewAccount.visible = false
			$CanvasLayer/Request.visible = false
			#$link.visible = false
		"hive":
			$CanvasLayer/SteemLink.visible = show
			
			$CanvasLayer/Request.visible = false
			$CanvasLayer/Login.visible = false
			$CanvasLayer/NewAccount.visible = false
		"request":
			$CanvasLayer/Request.visible = show
			$CanvasLayer/Request.load_account(data)
			$CanvasLayer/SteemLink.visible = false
			$CanvasLayer/Login.visible = false
			$CanvasLayer/NewAccount.visible = false
		_:
			$CanvasLayer/Request.visible = false
			$CanvasLayer/SteemLink.visible = false
			$CanvasLayer/Login.visible = false
			$CanvasLayer/NewAccount.visible = false
	
func _on_login_login(status):
	if status == 1:
		$Login.hide()
		pass

func _on_new_login(status):
	if status == 2:
		$NewAccount.hide()
	
#########################################################
#
# Image Functions
#
#########################################################

#func get_image(url,quality):
#	appdefaults = '"appPub":"'+str(appPub)+'","devPub":"'+str(devPub)+'"'
#	var data = ['{'+appdefaults+',"act":"get_image","image":"'+url+'","thetype":"url","quality":"'+quality+'"}',"image"]
#	var response = get_from_socket(data[0])
	
#	return response

func add_to_image_store(source,quality,filename):
	var response = '{"image":"exists"}'
	if !image_store.has(filename):
		var Imagetex = ImageTexture.new()
		if imgfile.file_exists("user://cache/Img/"+filename):
			imgfile.open("user://cache/Img/"+filename, File.READ)
			var imagesize = imgfile.get_len()
			if imagesize <= 3554421:
				var buffer = imgfile.get_buffer(imagesize)
				Imagedata.load_png_from_buffer(buffer)
				Imagedata.compress(0,0,90)
				if str(Imagetex).split("[")[1].split(":")[0] == "ImageTexture":
					Imagetex.create_from_image(Imagedata,0)
					image_store[filename] = Imagetex
			imgfile.close()
			response = '{"image":"stored"}'
			emit_signal("imagestored",[source,filename])
		else:
			response = '{"image":"fetching"}'
			if filename != "No_Image_found":
				get_timage(OpenSeed.openseed,"8080",filename)
	return response

func get_from_image_store(name):
	var response
	if image_store.has(name):
		response = image_store[name]
	return response

func set_image(songImage):
	var Imagetex = ImageTexture.new()
	OpenSeed.add_to_image_store(songImage,"medium",songImage)
	if imgfile.file_exists("user://cache/Img/"+songImage):
		imgfile.open("user://cache/Img/"+songImage, File.READ)
		var imagesize = imgfile.get_len()
		if imagesize <= 3554421:
			var buffer = imgfile.get_buffer(imagesize)
			var err = Imagedata.load_png_from_buffer(buffer)
			#Imagedata.compress(0,0,90)
			if err != OK:
				Imagetex = noimage
			else:
				if str(Imagetex).split("[")[1].split(":")[0] == "ImageTexture":
					Imagetex.create_from_image(Imagedata,0)
		else:
			print(songImage)
			print("too big")
			print(imagesize)
			Imagetex = noimage
		imgfile.close()
	else:
		Imagetex = noimage
		get_timage(OpenSeed.openseed,"8080",songImage)
			
	return Imagetex

func get_timage(url,port,thefile):
		var _postImg = thefile
		var http = HTTPRequest.new()
		http.use_threads = true
		self.add_child(http)
		http.set_download_file("user://cache/Img/"+thefile)
		var headers = [
			"User-Agent: Pirulo/1.0 (Godot)",
			"Accept: */*",
		]
		http.request("http://"+str(url)+":"+str(port)+"/ipfs/"+str(thefile),headers,false,HTTPClient.METHOD_GET)
		http.connect("request_completed",self,"image_download_complete")
		
func image_download_complete(result, response_code, headers, body):
	print("image file downloaded")
	pass
		
####################################
#
# Music functions
#
####################################

func get_audio(get_from_type,subopt = "all"):
	var response
	match get_from_type:
		"genres":
			response = []
			var genres = OpenSeed.get_from_socket('{"act":"genres","appPub":"'+str(OpenSeed.appPub)+'","devPub":"'+str(OpenSeed.devPub)+'"}')
			var list = parse_json(genres)
			if typeof(list) == TYPE_DICTIONARY:
				response = list["genres"]
		"genre":
			response = {}
			if subopt:
# warning-ignore:unused_variable
				var content = OpenSeed.get_from_socket('{"act":"genre_json","appPub":"'+str(OpenSeed.appPub)+'","devPub":"'+str(OpenSeed.devPub)+'","genre":"'+subopt+'"}')
	
	return response

func music_play(track):
	var file = File.new()
	var Oggy = AudioStreamOGGVorbis.new()
	emit_signal("audio","trackartist",track[1])
	emit_signal("audio","tracktitle",track[2])
	#emit_signal("audio","trackart",get_image(track[3],"low"))
	emit_signal("audio","playing",track[2])

	var song = "user://cache/Music/"+track[0]
	if file.file_exists(song):
		file.open(song, File.READ)
		var songlength = file.get_len()
		Oggy.set_data(file.get_buffer(songlength))
		#queue = Oggy.instance()
		$AudioStreamPlayer.set_stream(Oggy)
		file.close()
# warning-ignore:unused_variable
		var minutes = 0
		var seconds = 0
		if str($AudioStreamPlayer.get_stream().get_length() / 60).find(".") != -1:
			minutes = str($AudioStreamPlayer.get_stream().get_length() / 60).split(".")[0]
			seconds = (int(str($AudioStreamPlayer.get_stream().get_length() / 60).split(".")[1]) * 0.1) * 60
		else:
			minutes = str($AudioStreamPlayer.get_stream().get_length() / 60)
			seconds = 0
# warning-ignore:unused_variable
		var seconds_string = ""
		if seconds < 10:
			seconds_string = "0"+str(seconds)
		else:
			seconds_string = str(seconds)[0]+str(seconds)[1]
		#MusicBar1.emit_signal("songlength",	$AudioStreamPlayer.get_stream().get_length())
		#MusicBar1.emit_signal("timeleft",minutes+":"+seconds_string)
		$AudioStreamPlayer.play()
		set_history("playing",[track[2],track[1]])
	else:
		emit_signal("audio","download")
		$AudioStreamPlayer.stop()
		get_song("http://142.93.27.131","8080",track[0])

func get_song(url,port,thefile):
		$HTTPRequest.set_download_file("user://cache/Music/"+thefile)
		var headers = [
			"User-Agent: Pirulo/1.0 (Godot)",
			"Accept: */*"
		]
		$HTTPRequest.request(str(url)+":"+str(port)+"/ipfs/"+str(thefile),headers,false,HTTPClient.METHOD_GET)

func send_file(category,file):
	var headers = [
			"User-Agent: Pirulo/1.0 (Godot)",
			"Accept: */*"
		]
	var rest = '?category=image&file=@/home/benjamin/Pictures/wood-toad.jpg'
	$HTTPRequest.request("http://openseed.solutions:8689/upload",headers,false,HTTPClient.METHOD_POST,rest)

# warning-ignore:unused_argument
func _on_HTTPRequest_request_completed(_result, response_code, _headers, _body):
	
	if response_code == 200:
		emit_signal("socket_returns",["queue",simp_decrypt(appId,_body.get_string_from_utf8())])
		waiting = false
		#emit_signal("imagestored")
	pass # Replace with function body.

func _on_OpenSeed_new_tracks(_data):
	pass
	
func _on_OpenSeed_new_artists(_data):
	pass
	
func _on_Timer_timeout():
	pass # Replace with function body.

func _on_OpenSeed_update_loop(_last):
	pass # Replace with function body.

func _on_OpenSeed_conversations(_data):
	pass

func _on_OpenSeed_queue_updated(_data):
	pass
