extends Node

signal player_won(peer_id: int)

@rpc("any_peer", "call_local")
func on_player_reached_treasure(peer_id: int):
	ERLogger.info("Player %d reached the treasure and won!" % peer_id)
	emit_signal("player_won", peer_id)
	end_game(peer_id)

@rpc("any_peer", "call_local")
func on_player_died(dead_peer_id: int):
	ERLogger.debug("Received RPC that player %d died." % dead_peer_id)
	var local_id = NetworkManager.network_interface.get_unique_id()
	if local_id == dead_peer_id:
		ERLogger.info("You died. You Lose!")
	else:
		ERLogger.info("Player %d died. You Win!" % dead_peer_id)
		
	var winner_id = 0 if local_id == dead_peer_id else local_id
	end_game(winner_id)

func end_game(winner_id: int):
	ERLogger.info("Game Over. Disconnecting in 3 seconds...")
	await get_tree().create_timer(3.0).timeout
	NetworkManager.network_interface.disconnect_peer()
	get_tree().change_scene_to_file("res://Scenes/UI/Lobby.tscn")
