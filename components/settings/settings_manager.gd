extends Node

const path = "user://editor_preferences.cfg"
const fallback = "res://components/settings/fallback.cfg"

var config: ConfigFile
var default_config: ConfigFile

func _ready() -> void:
	if !FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.WRITE)
	config = ConfigFile.new()
	config.load(path)
	default_config = ConfigFile.new()
	default_config.load(fallback)

func get_setting(key: String, mod: String = "vanilla") -> Variant:
	return config.get_value(mod, key, default_config.get_value(mod, key))

#func set_setting(key: String, mod: String = "vanilla") -> void:
	#config.set_value()
