extends PanelContainer

@onready var block: Block = $Block
@onready var title: Control = $MarginContainer/Control

func _update_block() -> void:
	%TitleLabel.text = block.get_title()
	%ChildContainer.add_theme_constant_override(&"separation", block.get_arg("vertical_spacing"))
	title.visible = block.get_arg("show_title")

	custom_minimum_size.y = block.get_arg("size")

	if block.get_arg("use_preset_color"):
		remove_theme_stylebox_override(&"panel")
		theme_type_variation = &"Panel%s" % clampi(block.get_indents(), 0, 5)
		%TitleLabel.theme_type_variation = &"PanelLabel%s" % clampi(block.get_indents(), 0, 5)
	else:
		var style := get_theme_stylebox(&"panel").duplicate()
		if style is StyleBoxFlat:
			style.border_color = block.get_arg("color")
			add_theme_stylebox_override(&"panel", style)
			%TitleLabel.add_theme_color_override(&"font_color", block.get_arg("title_color"))
