extends Button

@export_file("*.togodoo") var template_path: String

func _pressed() -> void:
	if Settings.get_setting("vanilla", "editor/open_projects_in_new_window"):
		OS.create_process(OS.get_executable_path(), ["--project=%s" % template_path])
		get_tree().quit()
	else:
		FileManager.file_path = template_path
		get_tree().change_scene_to_file("res://scenes/main.tscn")
