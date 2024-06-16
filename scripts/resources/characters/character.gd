class_name Character
extends Resource

@export var name = "Character"
@export var level = 1
@export var max_health = 100:
    set(value):
        max_health = value + (level - 1) * 10
        health = max_health
@export var max_special_points = 10:
    set(value):
        max_special_points = value + (level - 1) * 2
        special_points = max_special_points
@export var attack = 10:
    set(value):
        attack = value + (level - 1) * 2
@export var special_attack = 10:
    set(value):
        special_attack = value + (level - 1) * 2
@export var defense = 10:
    set(value):
        defense = value + (level - 1) * 2
@export var special_defense = 10:
    set(value):
        special_defense = value + (level - 1) * 2
@export var speed = 10:
    set(value):
        speed = value + (level - 1) * 2
@export var moves: Array = []

var health = max_health
var special_points = max_special_points
var status_effects = []

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


func look() -> String:
    return name + ":\nLVL: " + str(level) + "\nHP: " + str(health) + "/" + str(max_health) + "\nSP: " + str(special_points) + "/" + str(max_special_points)


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
    var final_defense = defense

    for effect in status_effects:
        final_defense *= 1 + effect[0].damage_reduction / 100
    
    return max(final_damage - final_defense, 0)


func calculate_final_taken_special_damage(damage: int) -> int:
    var final_damage = damage
    var final_special_defense = special_defense

    for effect in status_effects:
        final_special_defense *= 1 + effect[0].special_damage_reduction / 100
    
    return max(final_damage - final_special_defense, 0)


func calculate_final_attack() -> int:
    var final_attack = attack

    for effect in status_effects:
        final_attack *= 1 + effect[0].damage_boost / 100
    
    return final_attack


func calculate_final_special_attack() -> int:
    var final_special_attack = special_attack

    for effect in status_effects:
        final_special_attack *= 1 + effect[0].special_damage_boost / 100
    
    return final_special_attack


func calculate_final_speed() -> int:
    var final_speed = speed

    for effect in status_effects:
        final_speed *= 1 + effect[0].speed_boost / 100
    
    return final_speed


func process_status_effects() -> String:
    var return_string = ""

    for i in range(status_effects.size() - 1, -1, -1):
        if status_effects[i][0].health_regeneration > 0:
            heal(status_effects[i][0].health_regeneration)
            return_string += name + " healed " + str(status_effects[i][0].health_regeneration) + " HP!\n"
        elif status_effects[i][0].health_regeneration < 0:
            take_raw_damage(-status_effects[i][0].health_regeneration)
            return_string += name + " took " + str(-status_effects[i][0].health_regeneration) + " damage!\n"
        
        status_effects[i][1] -= 1
        if status_effects[i][1] <= 0:
            status_effects.erase(i)

    return return_string
