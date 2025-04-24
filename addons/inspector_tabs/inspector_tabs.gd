extends EditorInspectorPlugin


var current_category:String = ""

var categories = [] # All categories/subclasses in the inspector
var tabs = [] # All tabs in the inspector

var categories_finish = false # Finish adding categories

var tab_bar:TabBar # Inspector Tabs
var base_control = EditorInterface.get_base_control()
var settings = EditorInterface.get_editor_settings()


var tab_can_change = false # Stops the TabBar from changing tab

var vertical_mode:bool = true # Tab position

enum TabStyle{
	TextOnly,
	IconOnly,
	TextAndIcon
}
var tab_style:int

var object_custom_classes = [] # Custom classes in the inspector

var is_filtering = false # are the search bar in use

var property_container # path to the editor inspector list of properties
var favorite_container # path to the editor inspector favorite list.

var UNKNOWN_ICON:ImageTexture # Use to check if the loaded icon is an unknown icon

func _can_handle(object):
	# We support all objects in this example.
	return true

# Start inspector loading
func _parse_begin(object: Object) -> void:
	tab_can_change = false
	tab_bar.clear_tabs()
	object_custom_classes.clear()
	
	#Get all the custom class and custom inherit class of the node
	var script:Script = object.get_script()
	if script != null:
		var c_name:String = ""
		for prop in script.get_script_property_list(): # List of inherit class, and variables (and other thing?)
			if prop.has("usage"):
				if prop["usage"] == PROPERTY_USAGE_CATEGORY:
					var check_script = load(prop["hint_string"]) # load script of subclass
					c_name = check_script.get_global_name()
					if c_name == "":
						c_name = prop["name"]
				elif prop["usage"] == 4102 and c_name != "": # class has @export
					object_custom_classes.append(c_name)
					c_name = ""

# getting the category from the inspector
func _parse_category(object: Object, category: String) -> void:
	# reset the list if its the first category
	if categories_finish:
		categories.clear()
		tabs.clear()
		categories_finish = false
		
	# Get custom class name
	var base_class = true
	if object_custom_classes.size() != 0:
		base_class = false
		var c_name = object_custom_classes.pop_front()
		if c_name != null:
			category = c_name

	# Add it to the list of categories and tabs
	# A disabled node such as PhysicsBody3D and CollisionObject3D didn't get its own tab.
	var load_icon = base_control.get_theme_icon(category, "EditorIcons")
	if not (base_class and load_icon == UNKNOWN_ICON):
		tabs.append(category)
	categories.append(category)

# Finished getting inspector categories
func _parse_end(object: Object) -> void:
	categories_finish = true
	
	update_tabs() # load tab
		
	tab_can_change = true
	
	# Set the selection to the previously selected tab
	var has = false
	for i in tabs.size():
		if tabs[i] == current_category:
			tab_bar.current_tab = i
			has = true
			break
	if not has:
		if tab_bar.tab_count != 0:
			tab_bar.current_tab = 0
	tab_resized()
	

# Is it not a custom class
func is_base_class(c_name:String) -> bool:
	if c_name.contains("."):return false
	for list in ProjectSettings.get_global_class_list():
		if list.class == c_name:
			return false
	return true
	
	
func get_class_icon(c_name:String) -> ImageTexture:
	var load_icon = null
	if c_name.ends_with(".gd"):# GDScript Icon
		load_icon = base_control.get_theme_icon("GDScript", "EditorIcons")
	else: # Get editor icon
		load_icon = base_control.get_theme_icon(c_name, "EditorIcons")
		
	if load_icon != UNKNOWN_ICON:
		return load_icon # Return if icon is not unknown
	
	# Get custom class icon
	for list in ProjectSettings.get_global_class_list():
		if list.class == c_name:
			if list.icon != "":
				var texture:Texture2D = load(list.icon)
				var image = texture.get_image()
				image.resize(load_icon.get_width(),load_icon.get_height())
				return ImageTexture.create_from_image(image)
			break
			
	# if icon not found just use the node disabled icon
	return base_control.get_theme_icon("NodeDisabled", "EditorIcons")

# add tabs
func update_tabs() -> void:
	for category in tabs:
		var load_icon = get_class_icon(category)
		
		if vertical_mode:
			# Rotate the image for the vertical tab
			var rotated_image = load_icon.get_image().duplicate()
			rotated_image.rotate_90(CLOCKWISE)
			load_icon = ImageTexture.create_from_image(rotated_image)
		
			
		match tab_style:
			TabStyle.TextOnly:
				tab_bar.add_tab(category,null)
			TabStyle.IconOnly:
				tab_bar.add_tab("",load_icon)
			TabStyle.TextAndIcon:
				tab_bar.add_tab(category,load_icon)
		tab_bar.set_tab_tooltip(tab_bar.tab_count-1,category)




func tab_changed(tab: int) -> void:
	if is_filtering: return
	var category_idx = -1
	var tab_idx = -1
	
	# Show nececary properties
	for i in property_container.get_children():
		if i.get_class() == "EditorInspectorCategory":
			category_idx += 1
			var load_icon = base_control.get_theme_icon(categories[category_idx], "EditorIcons")
			if not (is_base_class(categories[category_idx]) and load_icon == UNKNOWN_ICON):
				tab_idx += 1
		if tab_idx != tab:
			i.visible = false
		else:
			i.visible = true

# Is searching
func filter_text_changed(text:String):
	if text != "":
		for i in property_container.get_children():
			i.visible = true
		is_filtering = true
	else:
		is_filtering = false
		tab_changed(tab_bar.current_tab)

	
func tab_selected(tab):
	if tab_can_change:
		current_category = tabs[tab]
		
func tab_resized():
	if not vertical_mode:
		if tabs.size() != 0:
			tab_bar.max_tab_width = tab_bar.get_parent().get_rect().size.x/tabs.size()



# Change position mode
func change_vertical_mode(mode:bool):
	vertical_mode = mode
	if tab_bar:
		tab_bar.queue_free()
	vertical_mode = vertical_mode

	tab_bar = TabBar.new()
	tab_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tab_bar.clip_tabs = true
	tab_bar.rotation = PI/2
	tab_bar.mouse_filter =Control.MOUSE_FILTER_PASS
	var panel = Panel.new()
	tab_bar.add_child(panel)
	panel.anchor_right = 1
	panel.anchor_bottom = 1
	panel.show_behind_parent = true
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var inspector = EditorInterface.get_inspector().get_parent()
	
	tab_bar.tab_changed.connect(tab_changed)
	
	if not vertical_mode:
		inspector.add_child(tab_bar)
		inspector.move_child(tab_bar,3)

	update_tabs()

	if vertical_mode:
		EditorInterface.get_inspector().add_child(tab_bar)
		property_container.size_flags_horizontal = Control.SIZE_SHRINK_END
		favorite_container.size_flags_horizontal = Control.SIZE_SHRINK_END
		tab_bar.layout_direction =Control.LAYOUT_DIRECTION_RTL
		tab_bar.top_level = true
	else:
		property_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		favorite_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		property_container.custom_minimum_size.x = 0
		favorite_container.custom_minimum_size.x = 0
	tab_bar.resized.connect(tab_resized)
	tab_bar.tab_selected.connect(tab_selected)
	tab_resized()
			

func settings_changed() -> void:
	var tab_pos = settings.get("interface/inspector/tab_layout")
	if tab_pos != null:
		if tab_pos == 0:
			if vertical_mode != false:
				change_vertical_mode(false)
		else:
			if vertical_mode != true:
				change_vertical_mode(true)
	var style = settings.get("interface/inspector/tab_style")
	if style != null:
		if tab_style != style:
			tab_style = style
			
	if tab_pos != null and style != null:

		#Save settings
		var config = ConfigFile.new()
		# Store some values.
		config.set_value("Settings", "tab layout", tab_pos)
		config.set_value("Settings", "tab style", style)

		# Save it to a file (overwrite if already exists).
		var err = config.save(EditorInterface.get_editor_paths().get_config_dir()+"/InspectorTabsPluginSettings.cfg")
		if err != OK:
			print("Error saving inspector tab settings: ",error_string(err))
