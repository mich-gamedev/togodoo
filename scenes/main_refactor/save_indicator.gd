extends HBoxContainer

@onready var label: Label = $Label
@onready var icon: ModulateTextureRect = $IconOffset/Icon

var twn: Tween

func _ready() -> void:
	TreeManager.signals.file_saved.connect(_file_saved)
	TreeManager.signals.file_save_failed.connect(_file_err)

func _file_saved(path: String) -> void:
	icon.texture = preload("uid://bd67ndox07uia") # save.svg
	icon.theme_type_variation = &""
	label.theme_type_variation = &""
	label.text = path.get_file()
	if twn: twn.kill()
	twn = create_tween()
	twn.tween_property(self, ^"modulate:a", 0., 2.).from(1.)

func _file_err(path: String, err: Error) -> void:
	icon.texture = preload("uid://npomtk540ich") # x.svg
	icon.theme_type_variation = &"ErrorIcon"
	label.theme_type_variation = &"ErrorLabel"
	label.text = "ERROR: %s" % error_string(err)
	if twn: twn.kill()
	twn = create_tween()
	twn.tween_property(self, ^"modulate:a", 0., 2.).from(1.)
