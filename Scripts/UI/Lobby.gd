extends Control

const PORT = 7777
const ADDRESS = "127.0.0.1"

func _ready():
	ServerBrowser.server_found.connect(on_server_found)
	ServerBrowser.start_listening()
	
	if GameManager.disconnect_reason != "":
		show_error(GameManager.disconnect_reason)
		GameManager.disconnect_reason = ""

func on_server_found(ip: String, server_name: String):
	var join_btn_name = "JoinServer_" + ip.replace(".", "_")
	if not $VBoxContainer.has_node(join_btn_name):
		var btn = Button.new()
		btn.name = join_btn_name
		btn.text = "Join " + server_name + " [" + ip + "]"
		btn.pressed.connect(func(): on_join_specific_pressed(ip))
		$VBoxContainer.add_child(btn)

func on_join_specific_pressed(ip: String):
	ServerBrowser.stop()
	if NetworkManager.network_interface.start_client(ip, PORT):
		ERLogger.info("Joined %s:%d" % [ip, PORT])
		load_game_scene()

func show_error(msg: String):
	var dialog = AcceptDialog.new()
	dialog.dialog_text = msg
	dialog.title = "Disconnected"
	add_child(dialog)
	dialog.popup_centered()

func on_host_pressed():
	ServerBrowser.stop()
	ERLogger.debug("Host button pressed.")
	if NetworkManager.network_interface.start_host(PORT):
		ServerBrowser.start_broadcasting()
		ERLogger.info("Hosting on port %d" % PORT)
		load_game_scene()

func on_join_pressed():
	ServerBrowser.stop()
	ERLogger.debug("Join button pressed.")
	if NetworkManager.network_interface.start_client(ADDRESS, PORT):
		ERLogger.info("Joined %s:%d" % [ADDRESS, PORT])
		load_game_scene()

func load_game_scene():
	ERLogger.debug("Loading Main game scene.")
	get_tree().change_scene_to_file("res://Scenes/Level/Main.tscn")
