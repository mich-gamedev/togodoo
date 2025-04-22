extends Node

func _ready() -> void:
	Settings.signals.setting_changed.connect(_setting_changed)
	Settings.find_mods()
	var config = Settings.configs.vanilla[Settings.FALLBACK]
	for i in config.get_section_keys("properties"):
		_setting_changed("vanilla", i, Settings.get_setting("vanilla", i))

func _setting_changed(mod: String, key: String, value: Variant) -> void:
	if mod != "vanilla": return
	match key:
		"interface/ui_scale": get_window().content_scale_factor = value
		"interface/font":
			if !ResourceLoader.exists(value, "FontFile"):
				push_warning("Font path is invalid! %s" % value)
				return
			var font = FontFile.new()
			font.load_dynamic_font(value)
			font.multichannel_signed_distance_field = Settings.get_setting("vanilla", "interface/font_msdf")
			ThemeDB.get_project_theme().default_font = font
		"interface/font_msdf":
			ThemeDB.get_project_theme().default_font.multichannel_signed_distance_field = value
		"editor/single_window_mode":
			get_window().hide()
			get_window().gui_embed_subwindows = value
			get_window().show()
