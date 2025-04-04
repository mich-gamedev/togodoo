extends TextureRect

@onready var block: Block = $Block

func _update_block() -> void:
	texture = ImageTexture.create_from_image(Image.load_from_file(block.get_arg("image_path")))
	tooltip_text = block.get_title()
	if block.get_arg("width") <= 0:
		size_flags_horizontal = SIZE_EXPAND_FILL
		custom_minimum_size.x = 0
	else:
		size_flags_horizontal = SIZE_SHRINK_BEGIN
		custom_minimum_size.x = block.get_arg("width")
