extends Window

func _ready() -> void:
	#content_scale_factor = get_tree().root.content_scale_factor
	Settings.find_mods()
	for i in Settings.configs:
		var cfg := Settings.get_mod_info(i)
		var inst = Button.new()
		inst.icon = load(cfg.get_value("display", "icon", "res://resources/themes/x.svg"))
		inst.text = cfg.get_value("display", "display_name", "Untitled")
		inst.add_theme_constant_override("icon_max_width", 32)
		inst.add_theme_font_size_override("font_size", 16)
		inst.custom_minimum_size.y = 32
		%ModList.add_child(inst)
		inst.pressed.connect(_mod_pressed.bind(i))

func _on_close_requested() -> void:
	queue_free()

func _on_open_folder_pressed() -> void:
	OS.shell_show_in_file_manager("user://mods/")

func _mod_pressed(mod: String) -> void:
	var cfg := Settings.get_mod_info(mod)
	%Icon.texture = load(cfg.get_value("display", "icon"))
	%Title.text = "%s v%s" % [cfg.get_value("display", "display_name"), cfg.get_value("display", "version")]
	%Credits.text = "by %s" % cfg.get_value("display", "author")
	%Description.text = cfg.get_value("display", "description")
