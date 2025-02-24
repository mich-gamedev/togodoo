extends Tree

func _draw_tree_item(item: TreeItem, rect: Rect2) -> void:
	draw_texture(item.get_icon(0), rect.position)
	rect.position.x += item.get_icon(0).get_size().x
	rect.size.x -= item.get_icon(0).get_size().x
	draw_string(
		get_theme_font(&"font"),
		rect.position,
		item.get_text(0),
		HORIZONTAL_ALIGNMENT_LEFT,
		rect.size.x,
		get_theme_font_size(&"font_size"),
	)
