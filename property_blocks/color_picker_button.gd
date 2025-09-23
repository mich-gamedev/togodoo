extends ColorPickerButton

@onready var block: PropertyBlock = $"../../.."

func _ready() -> void:
	if block.property_usage_tags.has("color_low_refresh"):
		popup_closed.connect(block.property_change_emit)
	else:
		color_changed.connect(block.property_change_emit.unbind(1))

func _on_picker_created() -> void:
	get_popup().hide()

func _update(value: Variant):
	match typeof(value):
		TYPE_COLOR:
			color = value
		TYPE_STRING:
			var string := String(value)
			if string.is_valid_html_color():
				color = Color(string)
