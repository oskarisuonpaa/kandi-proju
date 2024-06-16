class_name Player
extends Character

@export var inventory: Dictionary = {}
@export var cores: Dictionary = {"Human": preload("res://resources/cores/human.tres").data}

var spells: Dictionary = {}
var core = cores["Human"]
var experience = 0
var experience_to_next_level = 100

func _init() -> void:
    core.set("level", level)


func add_items(items: Array) -> void:
    for item in items:
        if item is Spell:
            spells[item.name] = item
        elif item is Core:
            cores[item.data.name] = item.data
        else:
            if item.name in inventory:
                inventory[item.name].amount += 1
            else:
                inventory[item.name] = { "item": item, "amount": 1 }


func remove_item(item_name: String) -> void:
    if item_name in inventory:
        inventory[item_name].amount -= 1
        if inventory[item_name].amount <= 0:
            inventory.erase(item_name)


func look() -> String:
    return "HP: " + str(health) + "/" + str(max_health) + "\nSP: " + str(core.special_points) + "/" + str(core.max_special_points) + "\nCore: " + core.name + "\n"


func take_damage(damage: int) -> int:
    var damage_taken = calculate_final_taken_damage(damage)
    health -= damage_taken
    if health < 0:
        health = 0
    return damage_taken


func take_raw_damage(damage: int) -> int:
    health -= damage
    if health < 0:
        health = 0
    return damage


func take_special_damage(damage: int) -> int:
    var damage_taken = calculate_final_taken_special_damage(damage)
    health -= damage_taken
    if health < 0:
        health = 0
    return damage_taken


func heal(amount: int) -> int:
    health += amount
    if health > max_health:
        health = max_health
    return amount


func add_status_effect(status: StatusEffect, turns: int) -> void:
    var count = 0
    for i in range(status_effects.size()):
        if status_effects[i][0] == status:
            count += 1

    if count == 0 or count < status.max_stack:
        status_effects.append([status, turns])
    
    return


func remove_status_effect(status: String) -> void:
    for i in range(status_effects.size()):
        if status_effects[i][0] == status:
            status_effects.remove(i)
            break


func clear_status_effects():
    status_effects.clear()


func calculate_final_taken_damage(damage: int) -> int:
    var final_damage = damage
    var final_defense = core.defense

    for effect in status_effects:
        final_defense *= 1 + effect[0].damage_reduction / 100
    
    return max(final_damage - final_defense, 0)


func calculate_final_taken_special_damage(damage: int) -> int:
    var final_damage = damage
    var final_special_defense = core.special_defense

    for effect in status_effects:
        final_special_defense *= 1 + effect[0].special_damage_reduction / 100
    
    return max(final_damage - final_special_defense, 0)


func calculate_final_attack() -> int:
    var final_attack = core.attack

    for effect in status_effects:
        final_attack *= 1 + effect[0].damage_boost / 100
    
    return final_attack


func calculate_final_special_attack() -> int:
    var final_special_attack = core.special_attack

    for effect in status_effects:
        final_special_attack *= 1 + effect[0].special_damage_boost / 100
    
    return final_special_attack


func calculate_final_speed() -> int:
    var final_speed = core.speed

    for effect in status_effects:
        final_speed *= 1 + effect[0].speed_boost / 100
    
    return final_speed


func process_status_effects() -> String:
    var return_string = ""

    for i in range(status_effects.size() - 1, -1, -1):
        if status_effects[i][0].health_regeneration > 0:
            heal(status_effects[i][0].health_regeneration)
            return_string += "You healed " + str(status_effects[i][0].health_regeneration) + " HP!\n"
        elif status_effects[i][0].health_regeneration < 0:
            take_raw_damage(-status_effects[i][0].health_regeneration)
            return_string += "You took " + str(-status_effects[i][0].health_regeneration) + " damage!\n"
        
        status_effects[i][1] -= 1
        if status_effects[i][1] <= 0:
            status_effects.erase(i)

    return return_string


func gain_experience(amount: int) -> void:
    experience += amount

    while experience >= experience_to_next_level:
        experience -= experience_to_next_level
        level += 1
        experience_to_next_level = int(experience_to_next_level * 1.1)
        level += 1
        health = max_health
        special_points = max_special_points
        core.set("level", level)


func change_core(args: Array) -> bool:
    for _core in cores.keys():
        if _matches_object(args, _core):
            core = cores[_core]
            return true
    
    return false


func _matches_object(object: Array, target: String) -> bool:
    var target_words = target.to_lower().split(" ")

    if " ".join(object) in target and len(object) == len(target_words):
        return true
    elif len(object) == 1 and object[0] in target_words:
        return true
    else:
        return false
