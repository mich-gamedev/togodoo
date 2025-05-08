extends VBoxContainer

func _ready() -> void:
	TreeManager.signals.block_added.connect(_block_added)

func _block_added(dict: Dictionary, idx: int) -> void:
	pass
