extends Button

var block_type: String

func _get_drag_data(at_position: Vector2) -> Variant:
	var prev := ModulateTextureRect.new()
	prev.texture = icon
	set_drag_preview(prev)
	return block_type
