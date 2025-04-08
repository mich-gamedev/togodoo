extends HFlowContainer

@onready var block: Block = $Block

func _process(delta: float) -> void:
	var end_time = block.get_arg("end_time") if block.get_arg("end_time") != -1 else int(Time.get_unix_time_from_system())
	var dict = Time.get_time_dict_from_unix_time(end_time - block.get_arg("start_time"))
	%Time.text = "%02d:%02d:%02d" % [dict.hour, dict.minute, dict.second]

func _update_block() -> void:
	%Title.text = block.get_title()
	if block.get_arg("button_start"):
		block.set_arg("state", false)
		block.set_arg("start_time", int(Time.get_unix_time_from_system()))
		block.set_arg("end_time", -1)
		block.set_arg("button_start", false, false)
	if block.get_arg("button_continue"):
		block.set_arg("state", false)
		block.set_arg("end_time", -1)
		block.set_arg("button_continue", false, false)
	if block.get_arg("button_end"):
		block.set_arg("state", true)
		block.set_arg("end_time", int(Time.get_unix_time_from_system()))
		block.set_arg("button_end", false, false)
