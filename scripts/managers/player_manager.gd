class_name PlayerManager
extends Node

signal response_generated(response: String, delay: float)

@export var player: Player = Player.new()

func get_player() -> Player:
    return player


func add_items(items: Array) -> void:
    player.add_items(items)


func add_item(item: Item) -> void:
    player.add_item(item)


func remove_item(item_name: String) -> void:
    player.remove_item(item_name)


func get_item(args: Array) -> Item:
    for item in player.inventory.values():
        if _matches_object(args, item.item.name):
            return item.item
    
    return null



func add_spell(spell: Spell) -> void:
    player.add_spell(spell)


func look() -> String:
    return player.look()


func change_core(args: Array) -> void:
    if _matches_object(args, player.core.name.to_lower()):
        response_generated.emit(TextWrapper.system_text("You are already using that core."), 0.0)
        return

    if player.change_core(args):
        response_generated.emit("Transformed into " + player.core.name + "!", 0.0)
    else:
        response_generated.emit(TextWrapper.system_text("You don't have that core."), 0.0)

func get_inventory() -> Dictionary:
    return player.inventory


func get_inventory_string() -> String:
    if player.inventory.size() == 0:
        return "You have nothing in your inventory."
    
    var inventory_string = "Inventory:\n"
    var inventory = []

    for item in player.inventory.values():
        var item_string = (item.amount + " x ") if item.amount > 1 else "" + item.item.name + " - " + item.item.description
        inventory.append(item_string) 
    
    inventory_string += "\n".join(inventory)
    return inventory_string


func get_spells() -> Dictionary:
    return player.spells


func get_spells_string() -> String:
    if player.spells.size() == 0:
        return "You have no spells."
    
    var spells_string = "Spells:\n"
    var spells = []

    for spell in player.spells.values():
        spells.append(spell.name + " - " + spell.description)
    
    spells_string += "\n".join(spells)
    return spells_string


func get_cores() -> Dictionary:
    return player.cores


func get_cores_string() -> String:
    if player.cores.size() == 0:
        return "You have no cores."
    
    var core_string = "Cores:\n"
    var cores = []

    for core in player.cores.keys():
        cores.append(core)
    
    core_string += "\n".join(cores)
    return core_string


func get_health() -> int:
    return player.health


func get_max_health() -> int:
    return player.max_health


func _matches_object(object: Array, target: String) -> bool:
    var target_words = target.split(" ")

    if " ".join(object) in target and len(object) == len(target_words):
        return true
    elif len(object) == 1 and object[0] in target_words:
        return true
    else:
        return false
