extends CanvasLayer

@onready var p1_name = $MarginContainer/HBoxContainer/Player1Box/NameLabel
@onready var p1_hp = $MarginContainer/HBoxContainer/Player1Box/HPBar
@onready var p1_status = $MarginContainer/HBoxContainer/Player1Box/StatusLabel

@onready var p2_name = $MarginContainer/HBoxContainer/Player2Box/NameLabel
@onready var p2_hp = $MarginContainer/HBoxContainer/Player2Box/HPBar
@onready var p2_status = $MarginContainer/HBoxContainer/Player2Box/StatusLabel

var local_player: Node2D
var remote_player: Node2D

func _process(_delta):
	var players_node = get_node_or_null("/root/Main/Players")
	if not players_node: return
	
	for child in players_node.get_children():
		if child is PlayerController:
			if child.is_multiplayer_authority():
				if local_player != child:
					setup_player(child, true)
			else:
				if remote_player != child:
					setup_player(child, false)

func setup_player(player: PlayerController, is_local: bool):
	if is_local:
		local_player = player
		p1_name.text = "Player " + player.name + " (You)"
		p1_hp.max_value = player.max_health
		p1_hp.value = player.current_health
		update_status_ui(p1_status, player.current_status)
		
		player.health_changed.connect(func(hp): p1_hp.value = hp)
		player.status_changed.connect(func(st): update_status_ui(p1_status, st))
	else:
		remote_player = player
		p2_name.text = "Player " + player.name + " (Enemy)"
		p2_hp.max_value = player.max_health
		p2_hp.value = player.current_health
		update_status_ui(p2_status, player.current_status)
		
		player.health_changed.connect(func(hp): p2_hp.value = hp)
		player.status_changed.connect(func(st): update_status_ui(p2_status, st))

func update_status_ui(label: Label, status: int):
	match status:
		ElementRegistry.ElementStatus.Normal: 
			label.text = ""
			label.add_theme_color_override("font_color", Color.WHITE)
		ElementRegistry.ElementStatus.Burning: 
			label.text = "BURNING"
			label.add_theme_color_override("font_color", Color(1, 0.5, 0.5))
		ElementRegistry.ElementStatus.Soaked: 
			label.text = "SOAKED"
			label.add_theme_color_override("font_color", Color(0.5, 0.5, 1))
		ElementRegistry.ElementStatus.Frozen: 
			label.text = "FROZEN"
			label.add_theme_color_override("font_color", Color(0.5, 1, 1))
