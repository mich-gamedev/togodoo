extends Window



func _on_close_requested() -> void:
	queue_free()
