class_name FileManager extends Object

static var block_types: Dictionary

func load_mods() -> void:
	for type in DirAccess.get_directories_at("res://blocks/"):
		type += "/"
		for block in DirAccess.get_directories_at("res://blocks/" + type):
			block += "/"

			var dir := "res://blocks/" + type + block
			var meta := "res://blocks/" + type + block + "meta.cfg"

			if !FileAccess.file_exists(meta):
				push_error("No meta.cfg file found in %s" % dir)
				continue

			var cfg = ConfigFile.new()
			cfg.load(meta)
			if !cfg.has_section_key("logic", "format"):
				push_error("No logic>format key found in %s" % meta)
				continue

			block_types[cfg.get_value("logic", "format")] = dir
