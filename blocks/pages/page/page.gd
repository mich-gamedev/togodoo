extends PanelContainer

@onready var block: Block = $Block
@onready var title: Control = $MarginContainer/Control
@onready var margin: MarginContainer = $MarginContainer2

func _update_block() -> void:
	print("Page updated")
	%TitleLabel.text = block.get_title()
	%ChildContainer.add_theme_constant_override(&"separation", block.get_arg("vertical_spacing"))
	title.visible = block.get_arg("show_title")

	margin.add_theme_constant_override(&"margin_left", block.get_arg("margin"))
	margin.add_theme_constant_override(&"margin_top", block.get_arg("margin"))
	margin.add_theme_constant_override(&"margin_right", block.get_arg("margin"))
	margin.add_theme_constant_override(&"margin_bottom", block.get_arg("margin"))

	if block.get_arg("use_preset_color"):
		var style := get_theme_stylebox(&"panel")
		if style is StyleBoxFlat:
			style.border_color = Utils.COLORS[wrapi(block.get_indents() + Utils.ColorTags.OVERLAY_0, Utils.ColorTags.OVERLAY_0, Utils.ColorTags.TEXT)]
			%TitleLabel.add_theme_color_override(&"font_color", Utils.COLORS[clampi(block.get_indents() + Utils.ColorTags.SUBTEXT_0, Utils.ColorTags.OVERLAY_0, Utils.ColorTags.TEXT)])
	else:
		var style := get_theme_stylebox(&"panel")
		if style is StyleBoxFlat:
			style.border_color = block.get_arg("color")
			%TitleLabel.add_theme_color_override(&"font_color", block.get_arg("title_color"))
