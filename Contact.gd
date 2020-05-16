extends TextureRect
var fallback = preload("res://Img/avatar-default-symbolic.svg")

var title = ""
var pImage = ""
var imgfile = File.new()
var block = Image.new()
var texblock = ""
var the_img
var highlight = false
#var loadAnimDone = false
var OpenSeed
var Thicket	

# warning-ignore:unused_signal
signal refresh()
# Called when the node enters the scene tree for the first time.
func _ready():
	OpenSeed = get_node("/root/OpenSeed")
	Thicket = get_node("/root/Thicket")
	OpenSeed.openSeedRequest("get_image",[pImage,"low"])
	OpenSeed.connect("imagestored",self,"_on_Contact_refresh")

func set_box(image):
	var imagehash = "No_Image_found"
	if imagehash != "No_Image_found":
		var fromStore = OpenSeed.get_from_image_store(imagehash)
		if !fromStore:
			the_img = OpenSeed.set_image(imagehash)
		else:
			the_img = fromStore
			
	if the_img:
		self.set_texture(the_img)
	else:
		self.set_texture(fallback)

func _on_Contact_refresh(data):
	if data[1] != "No_Image_found" and data[0] == pImage:
	#var texbox = TextureRect.new()
		var fromStore = OpenSeed.get_from_image_store(data[1])
		if !fromStore:
			the_img = fallback
		else:
			the_img = fromStore
			
	if the_img:
		self.set_texture(the_img)
	else:
		self.set_texture(fallback)
