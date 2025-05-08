extends Button

@onready var property_block: PropertyBlock = $".."

func _on_display_requested(value: Variant) -> void:
	for i in property_block.property_usage_tags:
		if i.begins_with("button_title"): text = i.get_slice("=", 1)
		if i.begins_with("button_icon"): icon = load(i.get_slice("=", 1))
		if i.begins_with("button_min_width"):
			custom_minimum_size.x = i.get_slice("=", 1).to_float()
