extends Node2D
class_name MainGame

@export var player_scene: PackedScene
var modified_tiles: Dictionary = {}

func _ready():
	ERLogger.debug("MainGame _ready called. Is Server: " + str(NetworkManager.network_interface.is_server()))
	
	var level_gen = $LevelGenerator as LevelGenerator
	ERLogger.debug("Starting procedural generation.")
	level_gen.generate_level(12345)
	level_gen.apply_to_tilemap_layer($TileMapLayer)
	ERLogger.debug("Level generated and applied to TileMapLayer.")

	var ui_scene = preload("res://Scenes/UI/GameUI.tscn")
	add_child(ui_scene.instantiate())
	
	var mob_scene = preload("res://Scenes/UI/MobileControls.tscn")
	add_child(mob_scene.instantiate())
	
	NetworkManager.network_interface.server_disconnected.connect(func():
		GameManager.disconnect_reason = "Server Disconnected!"
		get_tree().change_scene_to_file("res://Scenes/UI/Lobby.tscn")
	)

	if NetworkManager.network_interface.is_server():
		ERLogger.info("Server spawning local host player.")
		spawn_player(NetworkManager.network_interface.get_unique_id())
		
		var peers = NetworkManager.network_interface.get_peers()
		ERLogger.debug("Found %d pre-connected peers." % peers.size())
		for p in peers:
			spawn_player(p)
			
		NetworkManager.network_interface.peer_connected.connect(spawn_player)
		NetworkManager.network_interface.peer_disconnected.connect(delete_player)

func spawn_player(id: int):
	ERLogger.info("Spawning player with ID: " + str(id))
	var player = player_scene.instantiate() as PlayerController
	player.name = str(id)
	

	if id != 1 and NetworkManager.network_interface.is_server():
		rpc_id(id, "sync_initial_tiles", modified_tiles)
	
	$Players.add_child(player)

@rpc("any_peer", "call_local")
func request_tile_change(pos: Vector2i, new_tile: int):
	$TileMapLayer.set_cell(pos, new_tile, Vector2i(0, 0))
	modified_tiles[pos] = new_tile
	
	if NetworkManager.network_interface.is_server():
		if new_tile == TileRegistry.TileType.Ash:
			get_tree().create_timer(3.0).timeout.connect(func():
				if $TileMapLayer.get_cell_source_id(pos) == TileRegistry.TileType.Ash:
					rpc("request_tile_change", pos, TileRegistry.TileType.Floor)
			)
		elif new_tile == TileRegistry.TileType.IceRiver:
			get_tree().create_timer(4.0).timeout.connect(func():
				if $TileMapLayer.get_cell_source_id(pos) == TileRegistry.TileType.IceRiver:
					rpc("request_tile_change", pos, TileRegistry.TileType.River)
			)

@rpc("any_peer")
func sync_initial_tiles(tiles: Dictionary):
	modified_tiles = tiles
	for pos in tiles:
		$TileMapLayer.set_cell(pos, tiles[pos], Vector2i(0, 0))

func delete_player(id: int):
	ERLogger.info("Deleting disconnected player: " + str(id))
	var player = get_node_or_null("Players/" + str(id))
	if player:
		player.queue_free()
