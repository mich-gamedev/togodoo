extends Control

@onready var button: PropertyBlock = $".."

func _on_button_display_requested(value: Variant) -> void:
	button
