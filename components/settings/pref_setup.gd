extends Node

func _ready() -> void:
	Settings.signals.setting_changed.connect(_setting_changed)
	Settings.signals.pck_loaded.connect(_pck_loaded)
	Settings.signals.mod_loaded.connect(_mod_loaded)
	Settings.find_mods()
	var config = Settings.configs.vanilla[Settings.FALLBACK]
	for i in config.get_section_keys("properties"):
		_setting_changed("vanilla", i, Settings.get_setting("vanilla", i))

func _setting_changed(mod: String, key: String, value: Variant) -> void:
	if mod != "vanilla": return
	match key:
		"interface/ui_scale":
			get_tree().root.content_scale_factor = value
			for i: Window in get_tree().root.find_children("*", "Window", true, false):
				i.content_scale_factor = value
		"interface/font":
			var font = FontFile.new()
			var err = font.load_dynamic_font(value)
			if err:
				push_error("Error on loading 'interface/font':", error_string(err))
			font.multichannel_signed_distance_field = Settings.get_setting("vanilla", "interface/font_msdf")
			get_theme().default_font = font
		"interface/font_msdf":
			get_theme().default_font.multichannel_signed_distance_field = value
		"interface/svg_oversampling":
			get_viewport().oversampling = value
		"interface/theme":
			if value == 6: return
			get_tree().root.theme = load("res://resources/themes/%s/main.theme" % [])
		"interface/custom_theme":
			if Settings.get_setting("vanilla", "interface/theme") != 6: return
			var theme := load(value)
			if theme is Theme:
				get_tree().root.theme = theme

func _pck_loaded(_path: String) -> void:
	get_tree().root.propagate_call.call_deferred("queue_redraw")

func _mod_loaded(mod: String) -> void:
	if mod == "vanilla":
		Settings.settings_formatting["FILE_PROJECTS"] = Settings.get_setting("vanilla", "file_system/valid_project_extensions")
		Settings.settings_formatting["DIR_PROJECTS"] = Settings.get_setting("vanilla", "file_system/default_project_folder")
		Settings.settings_formatting["DIR_IMAGES"] = Settings.get_setting("vanilla", "file_system/default_image_folder")

		var recents : Array = Array(Settings.get_setting("vanilla", "editor/recent_projects"))
		recents = recents.reduce(
			func(accum: Array, i):
				if !(i in accum): accum.append(i)
				return accum,
			[]
		)
		Settings.set_setting("vanilla", "editor/recent_projects", recents)

func get_theme() -> Theme:
	return get_tree().root.theme if get_tree().root.theme else ThemeDB.get_project_theme()
