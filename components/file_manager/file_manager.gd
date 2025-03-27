@icon("res://resources/themes/folder.svg")
class_name FileManager extends Object

static var block_types: Dictionary

static var usage_types: Dictionary

static var file_path: String


static func load_mods() -> void:
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
			if cfg.load(meta):
				push_error("meta.cfg file was invalid in %s" % dir)
				continue
			if !cfg.has_section_key("logic", "format"):
				push_error("No logic>format key found in %s" % meta)
				continue

			block_types[cfg.get_value("logic", "format")] = dir
	print(block_types)

	for i in DirAccess.get_files_at("res://property_blocks"):
		if ResourceLoader.exists("res://property_blocks/" + i, "PackedScene"): usage_types[i.get_basename()] = load("res://property_blocks/" + i)

static func get_block_config(path: String) -> ConfigFile:
	var config = ConfigFile.new()
	config.load(path.rstrip("/") + "/meta.cfg")
	return config
