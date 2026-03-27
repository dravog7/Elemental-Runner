extends Node
class_name ERLogger
static func debug(msg: String):
	if OS.is_debug_build():
		print("[DEBUG] ", msg)

static func info(msg: String):
	print("[INFO] ", msg)

static func error(msg: String):
	printerr("[ERROR] ", msg)
