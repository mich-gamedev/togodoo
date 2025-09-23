@tool
# Having a class name is handy for picking the effect in the Inspector.
class_name RichTextSubscript
extends RichTextEffect


# To use this effect:
# - Enable BBCode on a RichTextLabel.
# - Register this effect on the label.
# - Use [superscript param=2.0]hello[/superscript] in text.
var bbcode := "subscript"


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	char_fx.transform.x.x = .9
	char_fx.transform.y.y = .9
	char_fx.offset.y = +8
	return true
