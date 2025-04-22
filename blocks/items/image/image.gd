extends TextureRect

@onready var block: Block = $Block

func _update_block() -> void:
	var txt: Texture2D
	var img_path : String = String(block.get_arg("image_path"))
	if img_path.begins_with("res://"):
		txt = load(img_path)
	else:
		txt = ImageTexture.create_from_image(Image.load_from_file(block.get_arg("image_path")))
	texture = txt
	tooltip_text = block.get_title()
	if block.get_arg("width") <= 0:
		size_flags_horizontal = SIZE_EXPAND_FILL
		custom_minimum_size.x = 0
	else:
		size_flags_horizontal = SIZE_SHRINK_BEGIN
		custom_minimum_size.x = block.get_arg("width")
