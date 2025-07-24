@tool class_name ModulateTextureRect extends TextureRect

func _ready() -> void:
	if theme_type_variation == &"":
		theme_type_variation = &"ModulateTextureRect"
	theme_changed.connect(_theme_changed)

func _theme_changed() -> void:
	modulate = get_theme_color(&"tint")
