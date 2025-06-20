extends HBoxContainer

@onready var label: RichTextLabel = $RichTextLabel
@onready var link_icon: Button = $LinkIcon
@onready var block: Block = $Block

var twn: Tween

var is_overlapping_mouse: bool

func _update_block() -> void:
	label.text = ("# [u]%s" if is_overlapping_mouse else "# %s") % block.get_title().substr((0 if block.get_arg("show_hashtag") else 2))

func _mouse_entered() -> void:
	is_overlapping_mouse = true
	if twn: twn.kill()
	twn = create_tween()
	twn.tween_property(link_icon, ^"self_modulate:a", 1, 0.25)
	_update_block()

func _mouse_exited() -> void:
	is_overlapping_mouse = false
	if twn: twn.kill()
	twn = create_tween()
	twn.tween_property(link_icon, ^"self_modulate:a", 0, 0.25)
	_update_block()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			DisplayServer.clipboard_set("#%s" % block.get_title())
