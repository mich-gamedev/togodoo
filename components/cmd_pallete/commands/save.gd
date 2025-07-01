extends Command

func _is_valid() -> bool:
	return !TreeManager.items.is_empty()

func _run() -> void:
	PropertyBus.save_requested.emit("")
