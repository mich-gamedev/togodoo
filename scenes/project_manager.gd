extends Control

func _ready() -> void:
	print("started with following arguments: ", OS.get_cmdline_args())
	var args = OS.get_cmdline_args()
	for i in args:
		if i.get_slice("=", 0) == "--project":
			FileManager.file_path = i.get_slice("=", 1)
			get_tree().change_scene_to_file.call_deferred("res://scenes/main.tscn")

func _on_new_file_pressed() -> void:
	OS.create_process(OS.get_executable_path(), ["--project=res://project_templates/empty.togodoo"], true)
	get_tree().quit()

func _on_open_file_pressed() -> void:
	var dialog = FileDialog.new()
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.use_native_dialog = true
	dialog.add_filter("*.togodoo", "Togodoo Project")
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.current_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	dialog.file_selected.connect(_dialog_accepted)
	add_child(dialog)
	dialog.show()

func _dialog_accepted(path: String) -> void:
	OS.create_process(OS.get_executable_path(), ["--project=%s" % path], true)
	get_tree().quit()

func _on_contribute_pressed() -> void:
	OS.shell_open("https://github.com/mich-gamedev/togodoo")
