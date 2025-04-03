extends Window

@onready var nav_tree: Tree = %NavTree

func _ready() -> void:
	Settings.find_mods()
	var root = nav_tree.create_item()
	for mod: String in Settings.configs:
		var mod_item = nav_tree.create_item(root)
		mod_item.set_text(0, mod)
		var default_cfg := (Settings.configs[mod][Settings.FALLBACK] as ConfigFile)
		var user_cfg := (Settings.configs[mod][Settings.USER] as ConfigFile)

		var used_sections: Array[String]
		for setting in default_cfg.get_section_keys("properties"):
			if !(setting.get_slice("/", 0) in used_sections):
				var section = nav_tree.create_item(mod_item)
				section.set_text(0, (setting.get_slice("/", 0)))
				used_sections.append(section.get_text(0))

func _on_close_requested() -> void:
	queue_free()
