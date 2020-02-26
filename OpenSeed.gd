extends Node

# Setup variables 
var thread = Thread.new()

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
var mode = "socket"

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

#signals
# warning-ignore:unused_signal
signal login(status)
# warning-ignore:unused_signal
signal interface(type)
# warning-ignore:unused_signal
signal command(type,data)
# warning-ignore:unused_signal
signal linked()
signal userLoaded()

# warning-ignore:unused_signal
signal comment(info)

signal socket_returns(data)
signal chatdata(data)
signal sent_chat(data)
signal new_tracks(data)
signal historydata(data)

var dev_steem = ""
var dev_postingkey = ""
var appdefaults 

var threadedServer = StreamPeerTCP.new()
var server = StreamPeerTCP.new()

# Called when the node enters the scene tree for the first time.
# Default mode is set to login for obvious reasons. 
# Current interface options include:
# login: typical login interface also includes the new account creation dialogs
# steem: Interface to allow users to connect their game to the steem blockchain for cloud services.

func _ready():
	appdefaults = '"appPub":"'+str(appPub)+'","devPub":"'+str(devPub)+'"'
	pass
	
#func _process(delta):
#	pass

func _on_OpenSeed_command(type, data):
	match mode:
		"socket":
			match type:
				"loadUser":
					print("Loading user")
					loadUserData()
				"loadProfile":
					loadUserProfile(data)
				"history":
					get_history(data)
				"updateStatus":
					set_openseed_account_status(OpenSeed.token,data)
				"getStatus":
					get_openseed_account_status(data)

	pass # Replace with function body.



# Verifies the login creditials of an account on Openseed and reports back pass/fail/nouser.
func verify_account(u,p):
	appdefaults = '"appPub":"'+str(appPub)+'","devPub":"'+str(devPub)+'"'
	var data = '{"act":"accountcheck",'+ \
				appdefaults+','+ \
				'"username":"'+str(u)+'",'+ \
				'"passphrase":"'+str(p)+'",'+ \
				'}'
	var response = get_from_socket(str(data))
	return response
	
# Creates user based on the provided information. This user is added to the Openseed service. 
func create_user(u,p,e):
	appdefaults = '"appPub":"'+str(appPub)+'","devPub":"'+str(devPub)+'"'
	var response = get_from_socket('{"act":"create",'+appdefaults+',"username":"'+str(u)+'","passphrase":"'+str(p)+'","email":"'+str(e)+'" }')
	return response

# Links steem account to openseed account for future functions.
func steem_link(u):
	var response = get_from_socket('{"act":"link",'+appdefaults+',"steemname":"'+str(u)+'","username":"'+str(username)+'"}')
	return response

func get_steem_account(account):
	appdefaults = '"appPub":"'+str(appPub)+'","devPub":"'+str(devPub)+'"'
	var profile = get_from_socket('{"act":"getaccount",'+appdefaults+',"account":"'+account+'"}')
	return profile

func get_full_steem_account(account):
	appdefaults = '"appPub":"'+str(appPub)+'","devPub":"'+str(devPub)+'"'
	var profile = get_from_socket('{"act":"getfullaccount",'+appdefaults+',"account":"'+account+'"}')
	return profile

func get_openseed_account(account):
	appdefaults = '"appPub":"'+str(appPub)+'","devPub":"'+str(devPub)+'"'
	var profile = parse_json(get_from_socket('{"act":"openseed_profile",'+appdefaults+',"account":"'+account+'"}'))
	return profile

func get_openseed_account_status(account):
	appdefaults = '"appPub":"'+str(appPub)+'","devPub":"'+str(devPub)+'"'
	var status = parse_json(get_from_socket('{"act":"get_status",'+appdefaults+',"account":"'+account+'"}'))
	return status
	
func set_openseed_account_status(account_id,data):
	appdefaults = '"appPub":"'+str(appPub)+'","devPub":"'+str(devPub)+'"'
	var status = parse_json(get_from_socket('{"act":"update_status",'+appdefaults+',"account":"'+account_id+'","data":'+data+'}'))
	return status
	
func get_from_socket(data):
# warning-ignore:unused_variable
	var fullreturn = ""
	var _timeout = 18000
	if !server.is_connected_to_host():
		server.connect_to_host(openseed, 8688)
		while server.get_status() != 2:
			_timeout -= 1
	if server.is_connected_to_host():
		if server.get_status() == 2:
			server.put_data(data.to_utf8())
			var fromserver = server.get_data(1)
			var size = server.get_available_bytes()
			var therest = server.get_data(size)
			fullreturn = fromserver[1].get_string_from_utf8() + therest[1].get_string_from_utf8()
		
		server.disconnect_from_host()
		return (fullreturn)
	
func get_from_socket_threaded(data):
# warning-ignore:unused_variable
	var fullreturn = ""
	var _timeout = 18000
	var therest
	if !threadedServer.is_connected_to_host(): 
		threadedServer.connect_to_host(openseed, 8688)
		while threadedServer.get_status() != 2:
			_timeout -= 1
	if threadedServer.is_connected_to_host():
		if threadedServer.get_status() == 2 :
			threadedServer.put_data(data[0].to_utf8())
			var fromserver = threadedServer.get_data(1)
			var size = threadedServer.get_available_bytes()
			if size > 0:
				therest = threadedServer.get_data(size)
				fullreturn = fromserver[1].get_string_from_utf8() + therest[1].get_string_from_utf8()
			else:
				fullreturn = fromserver[1].get_string_from_utf8()
		if len(fullreturn) >= 0:
			call_deferred("returned_from_socket",data[1])
			
		return (fullreturn)
		
func returned_from_socket(type):
	var socket = thread.wait_to_finish()
	emit_signal("socket_returns",[type,socket])

func _on_OpenSeed_socket_returns(data):
	match data[0]:
		"profile":
			saveUserProfile(data[1])
		"chat":
			emit_signal("chatdata",data[1])
		"send_chat":
			emit_signal("sent_chat",data[1])
		"newtracks":
			emit_signal("new_tracks",data[1])
		"history":
			var jsoned = parse_json(data[1])
			if typeof(jsoned) == TYPE_DICTIONARY:
				emit_signal("historydata",jsoned["h"])
		_:
			print("unknown")
			
	pass # Replace with function body.
	
func _on_login_login(status):
	if status == 1:
		$Login.hide()
		pass

func _on_new_login(status):
	if status == 2:
		$NewAccount.hide()

func _on_link_linked():
	
	pass # Replace with function body.

# In this function we send OpenSeed a request to add new data to the leaderboard. Taking two variables u for user and d for the data.
# The data is then reformated into a transmitable json like format for get_leaderboard to parse.
# Note the need for a steem account (called steem) and a postingkey. As a developer you have the choice to use your own postingKey or require the user to use theirs. 
# a small fee 0.001 STEEM is required to post the memo on openseeds account to store the information on the chain. 

func update_leaderboard(u,d):
	appdefaults = '"appPub":"'+str(appPub)+'","devPub":"'+str(devPub)+'"'
	var dataformat = '{\\"'
	var datapoint = 0
	while datapoint < len(d):
		var repoint = d[datapoint].split(":")[0]+'\\":\\"'+d[datapoint].split(":")[1]
		dataformat = str(dataformat)+str(repoint)
		if datapoint+1 < len(d):
			dataformat = str(dataformat)+'\\",\\"'
		datapoint += 1
	dataformat = dataformat+'\\"}'
	var response = get_from_socket('{"act":"toleaderboard",'+appdefaults+',"username":"'+str(u)+'","data":"'+str(dataformat)+'","steem":"'+str(dev_steem)+'","postingkey":"'+str(dev_postingkey)+'"}')
	return response
	
# warning-ignore:unused_argument
func get_leaderboard(number):
	var scores = get_from_socket('{"act":"getleaderboard",'+appdefaults+'}')
	return scores
	
func get_history(account):
	var data = ['{"act":"get_history",'+ \
				'"appPub":"'+str(appPub)+'",'+ \
				'"devPub":"'+str(devPub)+'",'+ \
				'"account":"'+str(account)+'",'+ \
				'"apprange":"all",'+ \
				'"count":"10"}',"history"]
	#var _history = get_from_socket(str(data))
	if !thread.is_active():
			thread.start(self,"get_from_socket_threaded",data)
	#var jsoned = parse_json(_history)
	#if jsoned:
	#	emit_signal("socket_returns",["history",jsoned["h"]])
	#	return(jsoned["h"])
	
func set_history(action_type,action):
	var act = ""
	var act_type = ""
	var data = ""
	
	match action_type:
		"program_start":
			act_type = 1
		"program_stop":
			act_type = 2
		"playing":
			act_type = 3
		"purchase":
			act_type = 4
		"download":
			act_type = 5
		"linked":
			act_type = 6
		_:
			act_type = 0
	var packet = '"act":"update_history",'+appdefaults+',"type":"'+str(act_type)+'","account":"'+str(OpenSeed.token)+'"'
	data ='{"'+action_type+'":"'+action+'"}'
	get_from_socket('{'+packet+',"data":'+data+'}')
	pass

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
		var content = parse_json(file.get_as_text())
		if content:
			profile_name = content["data1"]["name"]
			profile_about = content["data2"]["about"]
			profile_image = content["data5"]["profile"]["profile_image"]
			profile_email = content["data1"]["email"]
			profile_phone = content["data1"]["phone"]
			emit_signal("userLoaded")
		else:
			print("no profile found")
			if !thread.is_active():
				#thread.start(self,"get_from_socket_threaded", ['{"act":"openseed_profile",'+appdefaults+',"account":"'+account+'"}',"profile"])
				profile =get_from_socket('{"act":"openseed_profile",'+appdefaults+',"account":"'+account+'"}')
				emit_signal("socket_returns",["profile",profile])
		file.close()
	else:
		print("no profile found")
		if !thread.is_active():
			#thread.start(self,"get_from_socket_threaded", ['{"act":"openseed_profile",'+appdefaults+',"account":"'+account+'"}',"profile"])
			profile = get_from_socket('{"act":"openseed_profile",'+appdefaults+',"account":"'+account+'"}')
			emit_signal("socket_returns",["profile",profile])
			
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
		set_openseed_account_status(token,'{"location":"0:1","chat":"Online"}')
		emit_signal("userLoaded")
		
	return content

func send_tokens(amount,to,what):
	appdefaults = '"appPub":"'+str(appPub)+'","devPub":"'+str(devPub)+'"'
	var response = get_from_socket('{"act":"payment",'+appdefaults+',"steemaccount":"'+str(steem)+'","amount":"'+str(amount)+'","to":"'+str(to)+'","for":"'+str(what)+'"}')
	return response

func send_like(post):
	appdefaults = '"appPub":"'+str(appPub)+'","devPub":"'+str(devPub)+'"'
	var response = get_from_socket('{"act":"like",'+appdefaults+',"steemaccount":"'+str(steem)+'","post":"'+post+'"}')
	return response

func follow(user):
	appdefaults = '"appPub":"'+str(appPub)+'","devPub":"'+str(devPub)+'"'
	var response = get_from_socket('{"act":"follow",'+appdefaults+',"steemaccount":"'+str(steem)+'","follow":"'+user+'"}')
	return response
	
func get_connections(account):
	appdefaults = '"appPub":"'+str(appPub)+'","devPub":"'+str(devPub)+'"'
	var profile = get_from_socket('{"act":"openseed_connections",'+appdefaults+',"account":"'+account+'"}')
	return profile
	
func send_comment(account,comment,post):
	appdefaults = '"appPub":"'+str(appPub)+'","devPub":"'+str(devPub)+'"'
	var response = get_from_socket('{"act":"comment",'+appdefaults+',"account":"'+account+'","comment":"'+comment+'","post":"'+post+'"}')
	return response


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
	pass
	
###########################################################################
#
# Chat Functions 
#
###########################################################################
	
# warning-ignore:shadowed_variable
func get_chat(username,account,last):
	var command = ['{"act":"get_chat","appPub":"'+ \
					str(appPub)+'","devPub":"'+str(devPub)+ \
					'","uid":"'+username+'","account":"'+account+ \
					'","room":"'+username+','+account+'","last":"'+str(last)+'"}' \
					,"chat"]
	if account:
		if !thread.is_active():
			thread.start(self,"get_from_socket_threaded",command)

# warning-ignore:shadowed_variable
func send_chat(message,username,account):
	var command = ['{"act":"send_chat","appPub":"'+str(appPub)+'","devPub":"'+str(devPub)+ \
					'","uid":"'+token+'","username":"'+username+'","account":"'+account+'","data":"'+message+'"}' \
					,"send_chat"]
	if account:
		if !thread.is_active():
			thread.start(self,"get_from_socket_threaded",command)
			#get_from_socket(command)
	
	

# Encryption Functions
	
func get_keys_for(users):
	appdefaults = '"appPub":"'+str(appPub)+'","devPub":"'+str(devPub)+'"'
	var response = get_from_socket('{"act":"update_key",'+appdefaults+',"thetype":"1","users":"'+users+'","uid":"'+token+'"}')
	return parse_json(response)["key"]

func simp_crypt(key,raw_data):
	key = key.replace("0","q")\
			.replace("1","a").replace("2","b")\
			.replace("3","c").replace("4","d")\
			.replace("5","F").replace("6","A")\
			.replace("7","Z").replace("8","Q")\
			.replace("9","T").replace("#","G")\
			.replace("!","B").replace(",","C")\
			.replace(" ","!").replace("/","S")\
			.replace("=","e").replace(":","c")\
			.replace("\n","n")
	var secret = ""
	var datanum = 0
	var digits = ""
	#//lets turn it into integers first//
	for t in raw_data.replace("%", ":percent:").replace("&", ":ampersand:"):
		var c = t.ord_at(0)
		digits += str(c)+" "
		
	var data = digits+str(str(" ").ord_at(0))
	while datanum < len(data):
		var keynum = 0
		while keynum < len(key):
			var salt = int(round(randf() * 40))
			if keynum < len(data) and salt % 3 == 0 and datanum < len(data):
				if data[datanum] == key[keynum]:
					var num = keynum
					while num < len(key) -1:
						secret = secret + key[num]
						num += 1
						if data[datanum] != key[num]:
							keynum = num
							secret = secret+data[datanum]
							break
						else:
							secret = secret + key[num]
				else:
					secret = secret+data[datanum]
				datanum += 1
			else:
				if keynum < len(key) and key[keynum]:
					secret = secret + key[keynum]
				else:
					keynum = 0
					secret = secret + key[keynum]
			keynum += 1
	return secret.replace(" ","zZz")

func simp_decrypt(key,raw_data):
	key = key.replace("0","q")\
			.replace("1","a").replace("2","b")\
			.replace("3","c").replace("4","d")\
			.replace("5","F").replace("6","A")\
			.replace("7","Z").replace("8","Q")\
			.replace("9","T").replace("#","G")\
			.replace("!","B").replace(",","C")\
			.replace(" ","!").replace("/","S")\
			.replace("=","e").replace(":","c")\
			.replace("\n","n")
			
	var key_stretch = key
	var message = ""
	var datanum = 0
	var decoded = ""

	var data = raw_data.replace("zZz"," ")

	if key_stretch != "":
		if len(data) > len(key_stretch):
			while len(key_stretch) < len(data):
				key_stretch = key_stretch + key

		while datanum < len(data):
			if key_stretch[datanum] != data[datanum]:
				if data[datanum]:
					message = message + data[datanum]
				else:break
			datanum = datanum + 1
			
		for c in message.split(" "):
			if len(c) <= 4:
				if int(c) < 255:
					decoded += char(int(c))
				else:
					decoded = "Unable to Decrypt"
	return decoded.replace(":percent:","%").replace(":ampersand:","&")

func _on_OpenSeed_interface(type):
	match type :
		"login":
			$CanvasLayer/Login.visible = true
			$CanvasLayer/NewAccount.visible = false
			#$link.visible = false
		"steem":
			$CanvasLayer/SteemLink.visible = true
			$CanvasLayer/Login.visible = false
			$CanvasLayer/NewAccount.visible = false
		_:
			$CanvasLayer/SteemLink.visible = false
			$CanvasLayer/Login.visible = false
			$CanvasLayer/NewAccount.visible = false
	pass # Replace with function body.



