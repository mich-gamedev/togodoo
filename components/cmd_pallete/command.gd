class_name Command

var name: String ## the displayed name in the command prompt list
var function: Callable ## the function that gets called when the command is picked
var is_valid: Callable ## the function to check if the command is valid and can be ran
var inputs: Array[InputEvent] ## shortcut events to activate commands
var icon: Texture2D ## the displayed icon in the command prompt list
var sub_options: Array[Variant] ## if not empty, will be used as a dropdown and provided as an argument to [member function]
