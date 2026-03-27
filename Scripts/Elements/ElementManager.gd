class_name ElementRegistry
extends RefCounted

enum ElementType { None = 0, Fire = 1, Water = 2, Ice = 3 }
enum ElementStatus { Normal = 0, Burning = 1, Soaked = 2, Frozen = 3 }

class ReactionResult:
    var damage_multiplier: float
    var new_status: int
    var status_duration: float
    
    func _init(mult: float, status: int, duration: float):
        damage_multiplier = mult
        new_status = status
        status_duration = duration

static var player_reactions: Dictionary = {
    "1_0": ReactionResult.new(1.0, ElementStatus.Burning, 4.0),
    "2_0": ReactionResult.new(1.0, ElementStatus.Soaked, 5.0),
    "3_0": ReactionResult.new(1.0, ElementStatus.Normal, 0.0),
    "1_2": ReactionResult.new(2.5, ElementStatus.Normal, 0.0), 
    "3_2": ReactionResult.new(1.5, ElementStatus.Frozen, 3.0),
    "2_1": ReactionResult.new(0.5, ElementStatus.Normal, 0.0),
    "1_3": ReactionResult.new(2.0, ElementStatus.Soaked, 2.0)
}

static func get_player_reaction(incoming: int, current: int) -> ReactionResult:
    var key = str(incoming) + "_" + str(current)
    if player_reactions.has(key):
        return player_reactions[key]
    return ReactionResult.new(1.0, current, 0.0)
