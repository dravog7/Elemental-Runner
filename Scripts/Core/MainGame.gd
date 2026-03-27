extends Node2D
class_name MainGame

@export var player_scene: PackedScene

func _ready():
	ERLogger.debug("MainGame _ready called. Is Server: " + str(NetworkManager.network_interface.is_server()))
	
	var level_gen = $LevelGenerator as LevelGenerator
	ERLogger.debug("Starting procedural generation.")
	level_gen.generate_level(12345)
	level_gen.apply_to_tilemap_layer($TileMapLayer)
	ERLogger.debug("Level generated and applied to TileMapLayer.")

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
	

	
	$Players.add_child(player)

func delete_player(id: int):
	ERLogger.info("Deleting disconnected player: " + str(id))
	var player = get_node_or_null("Players/" + str(id))
	if player:
		player.queue_free()
