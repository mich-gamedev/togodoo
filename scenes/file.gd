extends MenuButton

func _ready() -> void:
	get_popup().index_pressed.connect(_index_pressed)

func _index_pressed(index) -> void:
	match get_popup().get_item_text(index):
		"project manager":
			OS.create_process(OS.get_executable_path(), [])
		"save as":
			var dialog = FileDialog.new()
			dialog.access = FileDialog.ACCESS_FILESYSTEM
			dialog.use_native_dialog = true
			dialog.add_filter("*.togodoo", "Togodoo Project")
			dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
			dialog.current_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
			dialog.file_selected.connect(PropertyBus.save_requested.emit)
			add_child(dialog)
			dialog.show()
		"save":
			PropertyBus.save_requested.emit("")
		"open":
			var dialog = FileDialog.new()
			dialog.access = FileDialog.ACCESS_FILESYSTEM
			dialog.use_native_dialog = true
			dialog.add_filter("*.togodoo", "Togodoo Project")
			dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
			dialog.current_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
			dialog.file_selected.connect(_open_file)
			add_child(dialog)
			dialog.show()
		"show in filesystem":
			if FileManager.file_path.begins_with("res://"): return
			OS.shell_open(FileManager.file_path.get_base_dir())
		"open in text editor":
			if FileManager.file_path.begins_with("res://"): return
			OS.shell_open(FileManager.file_path)

func _open_file(path: String) -> void:
	OS.create_process(OS.get_executable_path(), ["--project=%s" % path])
