extends Node

func _ready() -> void:
	Settings.signals.setting_changed.connect(_setting_changed)
	Settings.signals.pck_loaded.connect(_pck_loaded)
	Settings.signals.mod_loaded.connect(_mod_loaded)
	Settings.find_mods()
	var config = Settings.configs.vanilla[Settings.FALLBACK]
	update_custom_theme()
	for i: String in config.get_section_keys("properties"):
		if i.begins_with("theme/") and !(i in ["theme/theme", "theme/custom_theme"]): continue
		_setting_changed("vanilla", i, Settings.get_setting("vanilla", i))

var custom : Theme = preload("uid://dn11g6an1ynwr").duplicate(true) # "res://resources/themes/catppuccin_macchiato/main.tres"

func _setting_changed(mod: String, key: String, value: Variant) -> void:
	if mod != "vanilla": return
	match key:
		"interface/ui_scale":
			get_tree().root.content_scale_factor = value if !is_zero_approx(value) else DisplayServer.screen_get_scale(DisplayServer.window_get_current_screen())
			for i: Window in get_tree().root.find_children("*", "Window", true, false):
				i.content_scale_factor = get_tree().root.content_scale_factor
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
		"theme/theme":
			var options: PackedStringArray
			for tag in Settings.get_setting_usage("vanilla", "theme/theme"):
				if tag.begins_with("options="):
					options = tag.trim_prefix("options=").split(";")
					break
			if options[value] == "custom":
				get_tree().root.theme = custom
				return
			if ResourceLoader.exists("res://resources/themes/%s/main.tres" % options[value]):
				var theme = load("res://resources/themes/%s/main.tres" % options[value])
				get_tree().root.theme = theme
		"theme/custom_theme":
			if Settings.get_setting("vanilla", "theme/theme") != 6: return
			var theme := load(value)
			if theme is Theme:
				get_tree().root.theme = theme
		_ when key.begins_with("theme/"):
			update_custom_theme()

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

func get_color(key: String) -> Color:
	return Settings.get_setting("vanilla", "theme/%s" % key)

func update_custom_theme() -> void:
	var bg := get_color("background")
	var light_bg := get_color("light_background")
	var dim := get_color("dim_text")
	var text := get_color("text")
	var highlight := get_color("text")
	var accent := get_color("accent")

	var focus := StyleBoxFlat.new()
	focus.bg_color = get_color("focus_background")
	focus.set_border_width_all(1)
	focus.border_color = get_color("focus_border")

	var focus_no_inside := focus.duplicate()
	focus_no_inside.bg_color = Color.TRANSPARENT

	var panel := StyleBoxFlat.new()
	panel.bg_color = get_color("panel_background")
	panel.set_border_width_all(1)
	panel.border_color = get_color("panel_border_1")

	var separator := StyleBoxLine.new()
	separator.color = dim
	separator.grow_begin = 0 ; separator.grow_end = 0

	var textbox := StyleBoxFlat.new()
	textbox.bg_color = get_color("textbox_background")
	textbox.set_border_width_all(1)
	textbox.border_color = get_color("textbox_border")

	var tmp: StyleBox

	# BlockHoverIndicator
	tmp = StyleBoxFlat.new()
	tmp.bg_color = get_color("focus_background")
	custom.set_stylebox(&"panel", &"BlockHoverIndicator", tmp)

	# Button  (no panels)
	custom.set_stylebox(&"focus", &"Button", focus)

	custom.set_color(&"font_color", &"Button", get_color("text"))
	custom.set_color(&"font_disabled_color", &"Button", get_color("dim_text"))
	custom.set_color(&"font_hover_pressed_color", &"Button", get_color("dim_text"))
	custom.set_color(&"font_hover_color", &"Button", get_color("highlight"))

	custom.set_color(&"icon_normal_color", &"Button", get_color("text"))
	custom.set_color(&"icon_disabled_color", &"Button", get_color("dim_text"))
	custom.set_color(&"icon_hover_pressed_color", &"Button", get_color("dim_text"))
	custom.set_color(&"icon_hover_color", &"Button", get_color("highlight"))

	# ButtonWithPanel
	tmp = StyleBoxFlat.new() ; tmp.set_border_width_all(1) ; tmp.border_width_bottom = 2
	#	Normal
	tmp.bg_color = get_color("button_normal_background") ; tmp.border_color = get_color("button_normal_outline")
	custom.set_stylebox(&"normal", &"ButtonWithPanel", tmp)
	#	Hover
	tmp = (tmp.duplicate() as StyleBoxFlat)
	tmp.bg_color = get_color("button_highlight_background") ; tmp.border_color = get_color("button_highlight_outline")
	custom.set_stylebox(&"hover", &"ButtonWithPanel", tmp)
	#	Disabled
	tmp = (tmp.duplicate() as StyleBoxFlat)
	tmp.bg_color = get_color("button_darken_background") ; tmp.border_color = get_color("button_darken_outline")
	custom.set_stylebox(&"disabled", &"ButtonWithPanel", tmp)
	#	Pressed
	tmp = (tmp.duplicate() as StyleBoxFlat)
	tmp.border_width_bottom = 1
	custom.set_stylebox(&"pressed", &"ButtonWithPanel", tmp)

	# CheckBox
	custom.set_color(&"checkbox_checked_color", &"CheckBox", get_color("accent"))
	custom.set_color(&"checkbox_unchecked_color", &"CheckBox", get_color("dim_text"))

	# DimIcon
	custom.set_color(&"tint", &"DimIcon", get_color("dim_text"))

	# ErrorIcon
	custom.set_color(&"tint", &"ErrorIcon", get_color("error"))

	# ErrorLabel
	custom.set_color(&"font_color", &"ErrorLabel", get_color("error"))


func get_path_formatted(path: String) -> String:
	match Settings.get_setting("vanilla", "editor/show_paths_as"):
		0: return path
		1:
			var slices = path.split("/")
			return slices[-2] + "/" + slices[-1]
		2:
			return path.get_file()
	return path
