@tool
extends EditorPlugin

var plugin

var filter_bar:LineEdit
var settings = EditorInterface.get_editor_settings()

func _enter_tree():
	plugin = preload("uid://d3uqhh42fvfuy").new()
	
	add_inspector_plugin(plugin)
	
	plugin.property_container = EditorInterface.get_inspector().get_child(0).get_child(2)
	plugin.favorite_container = EditorInterface.get_inspector().get_child(0).get_child(1)
	plugin.UNKNOWN_ICON = EditorInterface.get_base_control().get_theme_icon("", "EditorIcons")
	
	filter_bar = EditorInterface.get_inspector().get_parent().get_child(2).get_child(0)
	filter_bar.text_changed.connect(plugin.filter_text_changed)

	load_settings()

	var tab_pos = settings.get("interface/inspector/tab_layout")
	if tab_pos != null:
		if tab_pos == 0:
			plugin.change_vertical_mode(false)
		else:
			plugin.change_vertical_mode(true)
	
	plugin.tab_style = settings.get("interface/inspector/tab_style")
	
	
	settings.settings_changed.connect(plugin.settings_changed)
func load_settings():
	var config = ConfigFile.new()
	# Load data from a file.
	var err = config.load(EditorInterface.get_editor_paths().get_config_dir()+"/InspectorTabsPluginSettings.cfg")
	# If the file didn't load, ignore it.
	if err != OK:
		print("ERROR LOADING SETTINGS FILE")

	
	settings.set("interface/inspector/tab_layout", config.get_value("Settings", "tab layout",0))
	
	var property_info = {
		"name": "interface/inspector/tab_layout",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "Horizontal,Vertical",
	}
	settings.add_property_info(property_info)

	settings.set("interface/inspector/tab_style", config.get_value("Settings", "tab style",2))
	
	property_info = {
		"name": "interface/inspector/tab_style",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "Text Only,Icon Only,Text and Icon",
	}
	settings.add_property_info(property_info)
	
func _exit_tree():
	settings.set("interface/inspector/tab_layout", null)
	settings.set("interface/inspector/tab_style", null)
	
	plugin.property_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	plugin.favorite_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	plugin.property_container.custom_minimum_size.x = 0
	plugin.favorite_container.custom_minimum_size.x = 0


	remove_inspector_plugin(plugin)
	plugin.tab_bar.queue_free()





func _process(delta: float) -> void:
	# Reposition UI
	if plugin.vertical_mode:
		plugin.tab_bar.size.x = EditorInterface.get_inspector().size.y
		plugin.tab_bar.global_position = EditorInterface.get_inspector().global_position+Vector2(0,plugin.tab_bar.size.x)
		plugin.tab_bar.rotation = -PI/2
		plugin.property_container.custom_minimum_size.x = plugin.property_container.get_parent_area_size().x - plugin.tab_bar.size.y - 5
		plugin.favorite_container.custom_minimum_size.x = plugin.favorite_container.get_parent_area_size().x - plugin.tab_bar.size.y - 5
		plugin.property_container.position.x = plugin.tab_bar.size.y + 5
		plugin.favorite_container.position.x = plugin.tab_bar.size.y + 5
		

	if plugin.tab_bar.tab_count != 0:
		if EditorInterface.get_inspector().get_edited_object() == null:
			plugin.tab_bar.clear_tabs()
			



		
