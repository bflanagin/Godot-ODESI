extends TextureRect
var fallback = preload("res://Img/avatar-default-symbolic.svg")

var title = ""
var pImage = ""
var imgfile = File.new()
var block = ""
var texblock = ""
var highlight = false
#var loadAnimDone = false
var OpenSeed
var Thicket	

signal refresh()
# Called when the node enters the scene tree for the first time.
func _ready():
	OpenSeed = get_node("/root/OpenSeed")
	Thicket = get_node("/root/Thicket")
	#set_box(title,pImage)

func set_box(image,profileImage):
	if !imgfile.file_exists("user://cache/Img/"+image+"Profile"):
		get_timage(profileImage,title)
	else:
		set_texture(get_image("user://cache/Img/"+image+"Profile"))
		#get_parent().get_parent().get_parent().get_parent().textureList.append(get_texture())
	
func get_image(image):
	var Imagedata = block
	var Imagetex = texblock
	var err = ""
	if imgfile.file_exists(image):
		imgfile.open(image, File.READ)
		var imagesize = imgfile.get_len()
		if imagesize <= 2599782:
			var buffer = imgfile.get_buffer(imagesize)
			err = Imagedata.load_png_from_buffer(buffer)
			Imagedata.compress(0,0,90)
			if err != 0:
				err = Imagedata.load_jpg_from_buffer(buffer)
				Imagedata.compress(0,0,90)
				if err != 0:
					Imagetex = fallback
				else:
					Imagetex.create_from_image(Imagedata,0)
			else:
				Imagetex.create_from_image(Imagedata,0)
		else:
			print(image)
			print("too big")
			print(imagesize)
			Imagetex = fallback

		imgfile.close()
		return Imagetex
	
func get_timage(url,thefile):
	var file = File.new()
	if !file.file_exists("user://cache/Img/"+thefile+"Profile"):
		$HTTPRequest.set_download_file("user://cache/Img/"+thefile+"Profile")
		var headers = [
			"User-Agent: Pirulo/1.0 (Godot)",
			"Accept: */*"
		]
		$HTTPRequest.request(str(url),headers,false,HTTPClient.METHOD_GET)	

# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 200:
		set_texture(get_image($HTTPRequest.get_download_file()))

func _on_Contact_refresh():
	set_box(title,pImage)
	pass # Replace with function body.
