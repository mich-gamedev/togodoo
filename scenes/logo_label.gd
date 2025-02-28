extends Label

var check_indeces: Array[int]

func _ready() -> void:
	var checking_text = text
	while checking_text.contains("√"):
		var result = checking_text.find("√")
		check_indeces.append(result)
		checking_text[result] = "_"

func _on_timer_timeout() -> void:
	for i in check_indeces:
		text[i] = ["_", "√"].pick_random()
