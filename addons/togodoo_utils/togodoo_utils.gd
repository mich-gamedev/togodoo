@tool extends EditorPlugin

var dock: Control
const SCN_DOCK = preload("uid://ybfwl6ch82j") # "dock.tscn"

func _enter_tree() -> void:
	dock = SCN_DOCK.instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BL, dock)

func _exit_tree() -> void:
	remove_control_from_docks(dock)
	dock.free()
