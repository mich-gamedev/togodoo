extends Control

func _ready() -> void:
	TreeManager.load_file.call_deferred(FileManager.file_path if FileManager.file_path else "res://project_templates/notes.togodoo")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"save"):
		request_save()

func request_save() -> void:
	if FileManager.file_path and !FileManager.file_path.begins_with("res://"):
		TreeManager.save_file(FileManager.file_path)
	else:
			var dialog = FileDialog.new()
			dialog.access = FileDialog.ACCESS_FILESYSTEM
			dialog.use_native_dialog = true
			dialog.add_filter("*.togodoo", "Togodoo Project")
			dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
			dialog.current_path = Settings.get_setting("vanilla", "file_system/default_project_folder")\
			+ "/"\
			+ LineParser.format_file_name(Settings.get_setting("vanilla", "file_system/default_project_name"))
			dialog.file_selected.connect(TreeManager.save_file)
			add_child(dialog)
			dialog.show()
			return
