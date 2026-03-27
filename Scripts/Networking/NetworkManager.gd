extends Node

var network_interface: GodotP2PManager

func _ready():
    network_interface = GodotP2PManager.new(self)
