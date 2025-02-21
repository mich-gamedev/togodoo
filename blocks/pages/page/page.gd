extends PanelContainer

@onready var block: Block = $Block

func _update_block() -> void:
	%TitleLabel.text = block.get_title()
	if block.args.use_default_color:
		var style := get_theme_stylebox(&"panel")
		if style is StyleBoxFlat:
			style.border_color = Utils.COLORS[wrapi(block.get_indents(), Utils.ColorTags.OVERLAY_0, Utils.ColorTags.TEXT)]
			%TitleLabel.add_theme_color_override(&"font_color", style.border_color)
