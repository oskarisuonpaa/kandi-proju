class_name Enemy
extends Character

@export var experience_drop = 10
@export var drop_table: Dictionary = {}
@export var spells: Array = []


func look() -> String:
    return name + " -- LVL: " + str(level) + "\nHP: " + str(health) + "/" + str(max_health)


func _generate_loot() -> void:
    pass


func drop_loot() -> Array:
    return []
