extends Window

func _ready() -> void:
	#content_scale_factor = get_tree().root.content_scale_factor
	pass


func _on_close_requested() -> void:
	queue_free()
