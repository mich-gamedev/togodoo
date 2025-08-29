extends HSplitContainer

@onready var _prev_w: float = (get_child(1) as Control).size.x
@onready var _prev_mode: int = get_window().mode


func _ready() -> void:
	get_window().size_changed.connect(_win_size_changed)

func _win_size_changed() -> void:
	split_offset = int(size.x - _prev_w)

func _process(delta: float) -> void:
	if get_window().mode != _prev_mode:
		split_offset = int(size.x - _prev_w)
		_prev_mode = get_window().mode

func _dragged(offset:  int) -> void:
	_prev_w = (get_child(1) as Control).size.x
