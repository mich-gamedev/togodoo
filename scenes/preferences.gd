extends Window

@onready var nav_tree: Tree = %NavTree
@onready var options: VBoxContainer = %Options

const SEPERATOR = preload("res://scenes/new_block_type_seperator.tscn")

var contents: Dictionary[String, Control] = {}
var tree_contents: Dictionary[TreeItem, Control] = {}

func _ready() -> void:
	#content_scale_factor = get_tree().root.content_scale_factor
	Settings.find_mods()
	var root = nav_tree.create_item()
	for mod: String in Settings.configs:
		var mod_item = nav_tree.create_item(root)
		mod_item.set_text(0, mod)
		var default_cfg := (Settings.configs[mod][Settings.FALLBACK] as ConfigFile)
		var seperator = SEPERATOR.instantiate()
		options.add_child(seperator)
		contents["mod:%s" % mod] = seperator
		tree_contents[mod_item] = seperator
		seperator.get_node(^"%TypeLabel").text = mod

		var used_sections: Array[String]
		for setting in default_cfg.get_section_keys("properties"):
			if !(setting.get_slice("/", 0) in used_sections):
				var section = nav_tree.create_item(mod_item)
				section.set_text(0, setting.get_slice("/", 0))
				used_sections.append(section.get_text(0))
				var spacer_begin = Control.new(); spacer_begin.custom_minimum_size.y = 4; options.add_child(spacer_begin)
				var label := RichTextLabel.new()
				label.text = "[u][b]# " + setting.get_slice("/", 0).replace("_", " ")
				label.fit_content = true
				label.bbcode_enabled = true
				label.theme_type_variation = &"Header"
				options.add_child(label)
				contents["mod:%s section:%s"] = label
				tree_contents[section] = label
				var spacer_end = Control.new(); spacer_end.custom_minimum_size.y = 4; options.add_child(spacer_end)

			for tag in Settings.get_setting_usage(mod, setting):
				if FileManager.usage_types.has(tag):
					var inst := (FileManager.usage_types[tag] as PackedScene).instantiate() as PropertyBlock
					inst.name = setting.get_slice("/", 1).to_pascal_case()
					if inst.has_node("%PropertyName"): inst.get_node("%PropertyName").text = setting.get_slice("/", 1).replace("_", " ")
					inst.responsible_mod = mod
					inst.responsible_property = setting
					inst.property_usage_tags = Settings.get_setting_usage(mod, setting)
					inst.display_value.call_deferred(Settings.get_setting(mod, setting))
					#inst.tooltip_text = config.get_value("hints", setting, "")
					inst.for_setting = true
					options.add_child(inst)
					contents["mod:%s property:%s"] = inst
					break

func _on_close_requested() -> void:
	for mod: String in Settings.configs:
		Settings.save_config(mod)
	queue_free()

func jump_to(content: String) -> void:
	if !(content in contents): return
	var node = contents[content]
	print(node.position.y)
	%OptionsScroll.scroll_vertical = node.position.y

func jump_to_node(node: Control) -> void:
	print(node.position.y)
	%OptionsScroll.scroll_vertical = node.position.y

func _on_nav_tree_cell_selected() -> void:
	jump_to_node(tree_contents[nav_tree.get_selected()])
