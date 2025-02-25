extends PanelContainer

@onready var block: Block = $Block

func _update_block() -> void:
	print("Page updated")
	%TitleLabel.text = block.get_title()

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
