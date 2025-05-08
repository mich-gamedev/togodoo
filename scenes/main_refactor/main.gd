extends Control

func _ready() -> void:
	TreeManager.load_file.call_deferred(FileManager.file_path if FileManager.file_path else "res://project_templates/notes.togodoo")
