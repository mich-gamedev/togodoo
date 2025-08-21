extends FoldableContainer

@onready var block: Block = $Block
@onready var margin: MarginContainer = %HoverRect

func _update_block() -> void:
	title = block.get_title()
	%ChildContainer.add_theme_constant_override(&"separation", block.get_arg("vertical_spacing"))

	margin.add_theme_constant_override(&"margin_left", block.get_arg("margin"))
	margin.add_theme_constant_override(&"margin_top", block.get_arg("margin"))
	margin.add_theme_constant_override(&"margin_right", block.get_arg("margin"))
	margin.add_theme_constant_override(&"margin_bottom", block.get_arg("margin"))

	if block.get_arg("use_preset_color"):
		for i in [&"panel", &"title_collapsed_hover_panel", &"title_collapsed_panel", &"title_hover_panel", &"title_panel"]:
			var style := get_theme_stylebox(i)
	else:
		for i in [&"panel", &"title_collapsed_hover_panel", &"title_collapsed_panel", &"title_hover_panel", &"title_panel"]:
			var style := get_theme_stylebox(i)
			if style is StyleBoxFlat:
				style.border_color = block.get_arg("color")
		add_theme_color_override(&"font_color", block.get_arg("title_color"))
