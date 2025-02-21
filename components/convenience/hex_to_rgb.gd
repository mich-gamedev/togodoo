@tool
extends EditorScript

func _run() -> void:
	var current_color = Color(DisplayServer.clipboard_get())
	DisplayServer.clipboard_set("Color(%f, %f, %f, %f)" % [current_color.r, current_color.g, current_color.b, current_color.a])
