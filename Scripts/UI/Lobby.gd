extends Control

const PORT = 7777
const ADDRESS = "127.0.0.1"

func on_host_pressed():
    ERLogger.debug("Host button pressed.")
    if NetworkManager.network_interface.start_host(PORT):
        ERLogger.info("Hosting on port %d" % PORT)
        load_game_scene()

func on_join_pressed():
    ERLogger.debug("Join button pressed.")
    if NetworkManager.network_interface.start_client(ADDRESS, PORT):
        ERLogger.info("Joined %s:%d" % [ADDRESS, PORT])
        load_game_scene()

func load_game_scene():
    ERLogger.debug("Loading Main game scene.")
    get_tree().change_scene_to_file("res://Scenes/Level/Main.tscn")
