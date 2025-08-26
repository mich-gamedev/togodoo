extends Button

var block_type: String

func _get_drag_data(at_position: Vector2) -> Variant:
	var prev := ModulateTextureRect.new()
	prev.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	prev.size = Vector2.ONE * 16
	prev.position += Vector2.ONE * 4
	prev.texture = icon
	set_drag_preview(prev)
	return block_type
