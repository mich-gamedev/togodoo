extends Button

@export_file("*.togodoo") var template_path: String

var item_dicts: Dictionary[int, Dictionary] = {}
var items: Dictionary[int, Node] = {}

func _ready() -> void:
	%Label.text = template_path.get_file().trim_suffix(".togodoo").replace("_", " ")
	var file = FileAccess.open(template_path, FileAccess.READ)
	print("preview '%s' open status: " % %Label.text, error_string(FileAccess.get_open_error()))
	var i: int = 0
	while file.get_position() < file.get_length():
		var line = file.get_line()
		var parsed = LineParser.parse_line(line)
		if parsed.is_empty(): continue
		var added: bool = false
		for back in i:
			if item_dicts[i - back - 1].indents < parsed.indents:
				var parent_idx = i - back - 1
				var cfg = FileManager.get_block_config_by_type(parsed.type)
				var inst := (load(cfg.get_value("display", "preview")) as PackedScene).instantiate()
				items[parent_idx].get_node(^"%ChildContainer").add_child(inst)
				items[i] = inst
				added = true
				break #TODO continue here
		if !added:
			var cfg = FileManager.get_block_config_by_type(parsed.type)
			var inst := (load(cfg.get_value("display", "preview")) as PackedScene).instantiate()
			%PreviewContainer.add_child(inst)
			items[i] = inst
		item_dicts[i] = parsed
		i += 1

func _pressed() -> void:
	if Settings.get_setting("vanilla", "editor/open_projects_in_new_window"):
		OS.create_process(OS.get_executable_path(), ["--project=%s" % template_path])
		get_tree().quit()
	else:
		FileManager.file_path = template_path
		get_tree().change_scene_to_file(Settings.get_setting("vanilla", "editor/main_path"))
