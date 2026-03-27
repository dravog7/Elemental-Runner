class_name TileRegistry
extends RefCounted

enum TileType { Floor = 0, Wall = 1, River = 2, IceRiver = 3, Plant = 4, Ash = 5 }

static var tile_reactions: Dictionary = {
    "1_4": TileType.Ash,
    "3_2": TileType.IceRiver,
    "1_3": TileType.River
}

static func get_tile_reaction(element: int, tile: int) -> int:
    var key = str(element) + "_" + str(tile)
    if tile_reactions.has(key):
        return tile_reactions[key]
    return tile
