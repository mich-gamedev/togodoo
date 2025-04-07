extends Node

var undo := UndoRedo.new()

func add_method_action(name: String, do_func: Callable, undo_func: Callable, run_do: bool = false) -> void:
	undo.create_action(name)
	undo.add_do_method(do_func)
	undo.add_undo_method(undo_func)
	undo.commit_action(run_do)
