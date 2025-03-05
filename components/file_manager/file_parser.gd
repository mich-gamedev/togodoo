class_name LineParser extends Object

static func parse_line(line: String) -> Dictionary:
	var args = {}
	args.raw = line
	args.indents = line.get_slice("[", 0).length()

	var from = line.find("[")
	var to = line.find("]")
	args.raw_args =line.substr(from + 1, to - from - 1)
	var tags := Array(String(args.raw_args).split(" "))
	print("TAGS: ", tags)
	args.type = tags.pop_front()
	for i: String in tags:
		var expression = Expression.new()
		if expression.parse(i.get_slice("=", 1)):
			print("TAGS error: ", i.get_slice("=", 1))
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
