extends Area2D
class_name Treasure

func _ready():
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
    if body is PlayerController:
        if body.is_multiplayer_authority():
            var peer_id = body.name.to_int()
            if peer_id > 0:
                GameManager.rpc("on_player_reached_treasure", peer_id)
