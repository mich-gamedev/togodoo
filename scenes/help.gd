extends MenuButton

func _ready() -> void:
	get_popup().index_pressed.connect(_index_pressed)

func _index_pressed(index) -> void:
	match get_popup().get_item_text(index):
		"open docs":
			OS.shell_open("https://github.com/mich-gamedev/togodoo/wiki")
		"open github":
			OS.shell_open("https://github.com/mich-gamedev/togodoo")
