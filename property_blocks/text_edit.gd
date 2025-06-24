extends TextEdit

func _paste(caret_index: int) -> void:
	if Settings.get_setting("vanilla", "editor/format_links"):
		var regex := RegEx.new(); regex.compile(r".*?://.*?(?:\.[^ ]*)+")
		var copied = DisplayServer.clipboard_get()
		var result = regex.sub(
			copied,
			"[url %s][/url]" % copy,
			true
		)
		print("PASTE RESULT: ", result)
		insert_text_at_caret(result)
		var regex_search= regex.search(copied)
		if regex_search and regex_search.get_string() == copied:
			set_caret_column(get_caret_column() - 6)
	else:
		insert_text_at_caret(DisplayServer.clipboard_get())

func _on_bold_pressed() -> void:
	insert_text_at_caret("[b][/b]")
	grab_focus.call_deferred()
	set_caret_column(get_caret_column() - 4)

func _on_italics_pressed() -> void:
	insert_text_at_caret("[i][/i]")
	grab_focus.call_deferred()
	set_caret_column(get_caret_column() - 4)

func _on_underline_pressed() -> void:
	insert_text_at_caret("[u][/u]")
	grab_focus.call_deferred()
	set_caret_column(get_caret_column() - 4)

func _on_center_pressed() -> void:
	insert_text_at_caret("[center][/center]")
	grab_focus.call_deferred()
	set_caret_column(get_caret_column() - 9)

func _on_color_pressed() -> void:
	insert_text_at_caret("[color=][/color]")
	grab_focus.call_deferred()
	set_caret_column(get_caret_column() - 9)

func _ul_pressed() -> void:
	insert_text_at_caret("[ul][/ul]")
	grab_focus.call_deferred()
	set_caret_column(get_caret_column() - 5)

func _ol_pressed() -> void:
	insert_text_at_caret("[ol][/ol]")
	grab_focus.call_deferred()
	set_caret_column(get_caret_column() - 5)

func _strikethrough_pressed() -> void:
	insert_text_at_caret("[s][/s]")
	grab_focus.call_deferred()
	set_caret_column(get_caret_column() - 4)
