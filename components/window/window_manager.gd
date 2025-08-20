extends Node

func _ready() -> void:
	get_window().files_dropped.connect(_files_dropped)

func _files_dropped(files: PackedStringArray) -> void:
	for i: String in files:
		OS.create_process(OS.get_executable_path(), ["--project=%s" % i])
