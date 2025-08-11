extends Label

func _ready() -> void:
	Settings.signals.setting_changed.connect(_setting_changed)
	_setting_changed("vanilla", "interface/ascii_logo", Settings.get_setting("vanilla", "interface/ascii_logo"))

func _setting_changed(mod: String, setting: String, value: Variant) -> void:
	if mod == "vanilla" and setting == "interface/ascii_logo":
		text = value
