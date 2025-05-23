extends TextEdit

func _paste(caret_index: int) -> void:
	var regex := RegEx.new(); regex.compile(r".*?://.*?(?:\.[^ ]*)+")
	var copy = DisplayServer.clipboard_get()
	var result = regex.sub(
		copy,
		"[url %s][/url]" % copy,
		true
	)
	print("PASTE RESULT: ", result)
	insert_text_at_caret(result)
	var search = regex.search(copy)
	if search and search.get_string() == copy:
		set_caret_column(get_caret_column() - 6)
