extends Window

func _ready() -> void:
	content_scale_factor = Settings.get_setting("vanilla", "interface/ui_scale")
