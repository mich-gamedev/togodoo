extends Button

@onready var block: Block = $Block

func _update_block() -> void:
	icon = ImageTexture.create_from_image(Image.load_from_file(block.get_arg("icon")))
	text = block.get_title()

func _on_pressed() -> void:
	OS.create_process(OS.get_executable_path(), ["--project=%s" % block.get_arg("project")])
	if block.get_arg("close_current_project"): get_tree().quit()
