extends RefCounted
class_name GodotP2PManager

signal peer_connected(id: int)
signal peer_disconnected(id: int)
signal connected_to_server()
signal connection_failed()
signal server_disconnected()

var _parent_node: Node
var _peer: ENetMultiplayerPeer

func _init(parent_node: Node):
	_parent_node = parent_node
	_parent_node.multiplayer.peer_connected.connect(func(id): emit_signal("peer_connected", id))
	_parent_node.multiplayer.peer_disconnected.connect(func(id): emit_signal("peer_disconnected", id))
	_parent_node.multiplayer.connected_to_server.connect(func(): emit_signal("connected_to_server"))
	_parent_node.multiplayer.connection_failed.connect(func(): emit_signal("connection_failed"))
	_parent_node.multiplayer.server_disconnected.connect(func(): emit_signal("server_disconnected"))

func start_host(port: int) -> bool:
	ERLogger.debug("Attempting to start host on port %d" % port)
	_peer = ENetMultiplayerPeer.new()
	var err = _peer.create_server(port)
	if err != OK:
		ERLogger.error("Failed to start host: " + str(err))
		return false
	_parent_node.multiplayer.multiplayer_peer = _peer
	ERLogger.debug("Host started successfully.")
	return true

func start_client(address: String, port: int) -> bool:
	ERLogger.debug("Attempting to start client and connect to %s:%d" % [address, port])
	_peer = ENetMultiplayerPeer.new()
	var err = _peer.create_client(address, port)
	if err != OK:
		ERLogger.error("Failed to start client: " + str(err))
		return false
	_parent_node.multiplayer.multiplayer_peer = _peer
	ERLogger.debug("Client started successfully.")
	return true

func disconnect_peer():
	if _peer != null:
		_peer.close()
		_peer = null
	_parent_node.multiplayer.multiplayer_peer = null

func is_server() -> bool:
	return _parent_node.multiplayer.is_server()

func get_unique_id() -> int:
	return _parent_node.multiplayer.get_unique_id()

func get_peers() -> PackedInt32Array:
	return _parent_node.multiplayer.get_peers()
