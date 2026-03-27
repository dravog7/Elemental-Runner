extends Node

const BROADCAST_PORT = 7778
const BROADCAST_INTERVAL = 1.0

var udp_peer: PacketPeerUDP
var broadcast_timer: float = 0.0
var is_broadcasting: bool = false
var is_listening: bool = false

signal server_found(ip: String, name: String)

func _ready():
	udp_peer = PacketPeerUDP.new()

func _process(delta):
	if is_broadcasting:
		broadcast_timer += delta
		if broadcast_timer >= BROADCAST_INTERVAL:
			broadcast_timer = 0.0
			var msg = "ElementalRunnerServer:" + str(NetworkManager.network_interface.get_unique_id())
			udp_peer.set_dest_address("255.255.255.255", BROADCAST_PORT)
			udp_peer.put_packet(msg.to_utf8_buffer())
			
	if is_listening:
		while udp_peer.get_available_packet_count() > 0:
			var packet_bytes = udp_peer.get_packet()
			var packet = packet_bytes.get_string_from_utf8()
			var ip = udp_peer.get_packet_ip()
			if packet.begins_with("ElementalRunnerServer:"):
				var server_name = packet.split(":")[1]
				server_found.emit(ip, server_name)

func start_broadcasting():
	is_broadcasting = true
	is_listening = false
	udp_peer.close()
	udp_peer.set_broadcast_enabled(true)

func start_listening():
	is_broadcasting = false
	is_listening = true
	udp_peer.close()
	udp_peer.bind(BROADCAST_PORT)

func stop():
	is_broadcasting = false
	is_listening = false
	udp_peer.close()
