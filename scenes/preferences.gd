extends Window

const dir_prefs = "res://components/settings/defaults/"

var options: Dictionary

func _ready() -> void:
	for file in DirAccess.get_files_at(dir_prefs):
		var config = ConfigFile.new() ; config.load("%s/%s" % [dir_prefs, file])
		for key in config.get_section_keys("properties"):
			options[key] = {"usage": config.get_value("usage", key, "property_none")}

func _on_close_requested() -> void:
	queue_free()
