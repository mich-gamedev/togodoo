extends LineEdit

func _ready() -> void:
	right_icon = get_theme_icon(&"search") if has_theme_icon(&"search") else null
