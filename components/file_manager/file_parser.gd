class_name LineParser extends Object

static func parse_line(line: String) -> Dictionary:
	var args = {}
	args.raw = line
	args.indents = line.get_slice("[", 0).length()

	var from = line.find("[")
	var to = line.find("]")
	args.raw_args =line.substr(from + 1, to - from - 1)
	var filtered_args: String
	var in_quote := false
	for char in args.raw_args:
		if char == "\"":
			in_quote = !in_quote
		if char == " " and in_quote:
			char = "<SPACE>"
		filtered_args += char
	var tags := Array(filtered_args.split(" "))
	print("TAGS: ", tags)
	args.type = tags.pop_front()
	for i: String in tags:
		var expression = Expression.new()
		if expression.parse(i.trim_prefix(i.get_slice("=", 0) + "=").replace("<SPACE>", " ")):
			print("TAGS error: ", i.trim_prefix(i.get_slice("=", 0) + "=").replace("<SPACE>", " "))
			push_error(expression.get_error_text())
		args[i.get_slice("=", 0)] = expression.execute()
	args.title = line.lstrip(" ").replace(line.substr(from, to - from + 1), "").lstrip(" ").rstrip(" ")
	var regex = RegEx.new()
	regex.compile("\\[.*?\\]") #strips bbcode tags
	args.stripped_title = regex.sub(args.title, "", true)

	print(args)

	return args

static func parse_dict(dict: Dictionary) -> String:
	var config = FileManager.get_block_config(FileManager.block_types[dict.type])

	var tags: String
	if config.has_section("properties"): for i in config.get_section_keys("properties"):
		if dict.has(i) and dict[i] != config.get_value("properties", i):
			if tags.is_empty(): tags = " "
			match typeof(dict[i]):
				TYPE_STRING:
					tags += "%s=\"%s\"" % [i, dict[i]]
				TYPE_COLOR:
					tags += "%s=Color(%.3f,%.3f,%.3f,%.3f)" % [i, dict[i].r, dict[i].g, dict[i].b, dict[i].a]
				_:
					tags += "%s=%s" % [i, dict[i]]
	var indents: String = ""
	for i in dict.indents:
		indents += " "

	return indents + "[{type}{tags}] {title}".format({"type": dict.type, "tags": tags, "title": dict.title})
