extends Button

@onready var block: Block = $Block

func _update_block() -> void:
	if ResourceLoader.exists(block.get_arg("icon")):
		var tex = load(block.get_arg("icon"))
		icon = tex if tex else ImageTexture.create_from_image(Image.load_from_file(block.get_arg("icon")))
	else:
		icon = null
	text = block.get_title()
	disabled = !FileAccess.file_exists(block.get_arg("project"))
	size_flags_horizontal = SIZE_EXPAND_FILL if block.get_arg("expand") else SIZE_SHRINK_BEGIN
	size_flags_stretch_ratio = block.get_arg("expand_ratio")
	custom_minimum_size.x = block.get_arg("min_size")

func _on_pressed() -> void:
	OS.create_process(OS.get_executable_path(), ["--project=%s" % block.get_arg("project")])
	if block.get_arg("close_current_project"): get_tree().quit()
