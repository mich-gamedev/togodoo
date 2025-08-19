extends Window

func _ready() -> void:
	content_scale_factor = Settings.get_setting("vanilla", "interface/ui_scale")

func _on_save_pressed() -> void:
	PropertyBus.save_requested.emit("")
	await PropertyBus.save_successful
	get_tree().quit()

func _on_discard_pressed() -> void:
	get_tree().quit()

func _on_cancel_pressed() -> void:
	queue_free()
