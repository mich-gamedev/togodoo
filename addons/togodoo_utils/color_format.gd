@tool extends HBoxContainer
@onready var color_picker_button: ColorPickerButton = $ColorPickerButton
@onready var line_edit: LineEdit = $LineEdit

func _color_picker_button_color_changed(color:  Color) -> void:
	line_edit.text = var_to_str(color)

func _line_edit_text_submitted(txt:  String) -> void:
	var value = str_to_var(txt)
	if typeof(value) == TYPE_COLOR:
		color_picker_button.color = value

func _button_pressed() -> void:
	DisplayServer.clipboard_set(line_edit.text)
