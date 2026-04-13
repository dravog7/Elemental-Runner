extends CharacterBody2D
class_name PlayerController

@export var speed: float = 300.0
@export var max_health: int = 100
@export var projectile_scene: PackedScene

signal health_changed(new_health: int)
signal status_changed(new_status: int)

var current_health: int
var current_status: int = ElementRegistry.ElementStatus.Normal
var status_timer: float = 0.0
var active_element: int = ElementRegistry.ElementType.Fire

func _enter_tree():
	var peer_id: int = name.to_int()
	if peer_id > 0:
		set_multiplayer_authority(peer_id)

func _ready():
	add_to_group("player")
	var peer_id: int = name.to_int()
	ERLogger.debug("PlayerController _ready() mapping for Peer ID: " + str(peer_id))
	
	var main_game = get_node_or_null("/root/Main")
	if main_game:
		var level_gen = main_game.get_node_or_null("LevelGenerator")
		var map_layer = main_game.get_node_or_null("TileMapLayer")
		if level_gen and map_layer:
			var valid_spots = []
			for x in range(level_gen.width):
				for y in range(5, 10):
					if level_gen.grid[x][y] == TileRegistry.TileType.Floor:
						valid_spots.append(Vector2i(x, y))
			
			if valid_spots.size() > 0:
				var rng = RandomNumberGenerator.new()
				rng.seed = peer_id + 777
				var random_spot = valid_spots[rng.randi() % valid_spots.size()]
				position = map_layer.map_to_local(random_spot)
	
	ERLogger.debug("Init spawn position: " + str(position))
	if peer_id > 0:
		var sync_node = get_node_or_null("MultiplayerSynchronizer")
		if sync_node:
			sync_node.set_multiplayer_authority(peer_id)
			
		var sprite = get_node_or_null("Sprite2D")
		if sprite:
			if peer_id == 1:
				sprite.texture = load("res://assets/player1.png")
			else:
				sprite.texture = load("res://assets/player2.png")
	
	if is_multiplayer_authority():
		var cam = get_node_or_null("Camera2D")
		if cam:
			cam.enabled = true
			cam.make_current()

	current_health = max_health

func _physics_process(delta: float):
	if not is_multiplayer_authority():
		return
		
	process_status(delta)
	
	if current_status == ElementRegistry.ElementStatus.Frozen:
		velocity = Vector2.ZERO
		move_and_slide()
		return
		
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var current_speed = speed
	if current_status == ElementRegistry.ElementStatus.Soaked:
		current_speed *= 0.8
		
	velocity = input_dir * current_speed
	move_and_slide()

func _unhandled_input(event: InputEvent):
	if not is_multiplayer_authority():
		return
		
	if current_status == ElementRegistry.ElementStatus.Frozen:
		return
		
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				active_element = ElementRegistry.ElementType.Fire
			KEY_2:
				active_element = ElementRegistry.ElementType.Water
			KEY_3:
				active_element = ElementRegistry.ElementType.Ice
				
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		shoot(active_element)

func shoot(elem: int):
	var mouse_pos = get_global_mouse_position()
	var shoot_dir = (mouse_pos - global_position).normalized()
	rpc("spawn_projectile", elem, shoot_dir)

func set_active_element(elem: int):
	if is_multiplayer_authority():
		active_element = elem

func shoot_from_virtual(aim_dir: Vector2):
	if is_multiplayer_authority():
		rpc("spawn_projectile", active_element, aim_dir)

@rpc("any_peer", "call_local")
func spawn_projectile(elem: int, shoot_dir: Vector2):
	if projectile_scene == null: return
	var proj = projectile_scene.instantiate() as Projectile
	proj.element = elem
	proj.direction = shoot_dir
	proj.owner_id = name.to_int()
	proj.global_position = global_position + shoot_dir * 35.0
	get_parent().add_child(proj)

func process_status(delta: float):
	if current_status != ElementRegistry.ElementStatus.Normal:
		status_timer -= delta
		if status_timer <= 0:
			rpc("clear_status")

@rpc("any_peer", "call_local")
func handle_element_hit(incoming_element: int, base_damage: int):
	if not is_multiplayer_authority(): return
	
	var reaction = ElementRegistry.get_player_reaction(incoming_element, current_status)
	var final_damage = round(base_damage * reaction.damage_multiplier)
	
	current_health -= final_damage
	health_changed.emit(current_health)
	ERLogger.info("Player %s took %d damage. HP: %d" % [name, final_damage, current_health])
	
	if reaction.new_status != current_status:
		rpc("apply_status", reaction.new_status, reaction.status_duration)
		
	if current_health <= 0:
		ERLogger.debug("Player " + name + " health reached 0. Triggering die().")
		rpc("die")

@rpc("any_peer", "call_local")
func apply_status(status_int: int, duration: float):
	current_status = status_int
	status_changed.emit(current_status)
	if duration > 0: status_timer = duration
	
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		match current_status:
			ElementRegistry.ElementStatus.Normal: sprite.modulate = Color.WHITE
			ElementRegistry.ElementStatus.Burning: sprite.modulate = Color(1, 0.5, 0.5)
			ElementRegistry.ElementStatus.Soaked: sprite.modulate = Color(0.5, 0.5, 1)
			ElementRegistry.ElementStatus.Frozen: sprite.modulate = Color(0.5, 1, 1)

@rpc("any_peer", "call_local")
func clear_status():
	current_status = ElementRegistry.ElementStatus.Normal
	status_changed.emit(current_status)
	var sprite = get_node_or_null("Sprite2D")
	if sprite: sprite.modulate = Color.WHITE

@rpc("any_peer", "call_local")
func die():
	print("Player %s died!" % name)
	queue_free()
