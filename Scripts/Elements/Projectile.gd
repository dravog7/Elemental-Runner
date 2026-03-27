extends Area2D
class_name Projectile

@export var element: int = ElementRegistry.ElementType.Fire
@export var speed: float = 500.0
@export var base_damage: int = 10

var direction: Vector2 = Vector2.ZERO
var owner_id: int = 0

func _ready():
    body_entered.connect(_on_body_entered)
    var sprite = get_node_or_null("Sprite2D")
    if sprite:
        match element:
            ElementRegistry.ElementType.Fire: sprite.modulate = Color.RED
            ElementRegistry.ElementType.Water: sprite.modulate = Color.BLUE
            ElementRegistry.ElementType.Ice: sprite.modulate = Color.CYAN

func _physics_process(delta: float):
    position += direction * speed * delta

func _on_body_entered(body: Node2D):
    if body is PlayerController:
        var peer_id: int = body.name.to_int()
        if peer_id == owner_id:
            return
            
        if body.is_multiplayer_authority():
            body.handle_element_hit(element, base_damage)
        queue_free()
    elif body is TileMapLayer:
        var tilemap = body as TileMapLayer
        # Check slightly forward in the direction of travel to be well inside the tile boundary
        var hit_pos = global_position + direction * 16.0
        var map_pos = tilemap.local_to_map(tilemap.to_local(hit_pos))
        var current_tile = tilemap.get_cell_source_id(map_pos)
        
        if current_tile != -1:
            var new_tile = TileRegistry.get_tile_reaction(element, current_tile)
            if new_tile != current_tile:
                tilemap.set_cell(map_pos, new_tile, Vector2i(0, 0))
                
                # Setup delayed reactions like fire turning plant to ash, then ash to floor
                if new_tile == TileRegistry.TileType.Ash:
                    tilemap.get_tree().create_timer(3.0).timeout.connect(func():
                        if is_instance_valid(tilemap) and tilemap.get_cell_source_id(map_pos) == TileRegistry.TileType.Ash:
                            tilemap.set_cell(map_pos, TileRegistry.TileType.Floor, Vector2i(0, 0))
                    )
                elif new_tile == TileRegistry.TileType.IceRiver:
                    tilemap.get_tree().create_timer(4.0).timeout.connect(func():
                        if is_instance_valid(tilemap) and tilemap.get_cell_source_id(map_pos) == TileRegistry.TileType.IceRiver:
                            tilemap.set_cell(map_pos, TileRegistry.TileType.River, Vector2i(0, 0))
                    )
                    
        queue_free()
