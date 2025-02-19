class_name LineParser extends Object

static func parse_line(line: String) -> Dictionary:
	var args = {}
	args.raw = line
	args.indents = line.get_slice("[", 0).length()

	var from = line.find("[")
	var to = line.find("]")
	args.raw_args =line.substr(from + 1, to - from - 1)
	var tags := Array(String(args.raw_args).split(" "))
	args.type = tags.pop_front()
	for i: String in tags:
		var expression = Expression.new()
		if expression.parse(i.get_slice("=", 1)):
			push_error(expression.get_error_text())
		args[i.get_slice("=", 0)] = expression.execute()
	args.title = line.lstrip(" ").replace(line.substr(from, to - from + 1), "").lstrip(" ").rstrip(" ")
	var regex = RegEx.new()
	regex.compile("\\[.*?\\]") #strips bbcode tags
	args.stripped_title = regex.sub(args.title, "", true)

	print(args)

	return args
