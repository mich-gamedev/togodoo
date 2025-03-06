extends FileDialog

@onready var property: PropertyBlock = $".."
@onready var line_edit: LineEdit = $"../LineEdit"

func _on__display_requested(value: Variant) -> void:
	pass

func _on_button_pressed() -> void:
	for i in property.property_usage_tags:
		if "file_filters=" in i:
			filters = i.get_slice("=", 1).replace("/", ",").split("&")
	show()

func _on_file_selected(path: String) -> void:
	line_edit.text = path
	property.property_change_emit()
