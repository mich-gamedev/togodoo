extends ColorPickerButton

@onready var block: PropertyBlock = $"../../.."

func _ready() -> void:
	if block.property_usage_tags.has("color_low_refresh"):
		popup_closed.connect(block.property_change_emit)
	else:
		color_changed.connect(block.property_change_emit.unbind(1))

func _on_picker_created() -> void:
	get_popup().hide()
