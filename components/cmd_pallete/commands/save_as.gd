extends Command

func _is_valid() -> bool:
	return !TreeManager.items.is_empty()

func _run() -> void:
	var dialog := FileDialog.new()
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.use_native_dialog = true
	dialog.add_filter("*.togodoo", "Togodoo Project")
	dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	dialog.current_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	dialog.file_selected.connect(PropertyBus.save_requested.emit)
	Engine.get_main_loop().current_scene.add_child(dialog)
	dialog.show()
