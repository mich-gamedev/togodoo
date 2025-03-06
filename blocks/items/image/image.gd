extends TextureRect

@onready var block: Block = $Block

func _update_block() -> void:
	texture = ImageTexture.create_from_image(Image.load_from_file(block.get_arg("image_path")))
	tooltip_text = block.get_title()
