extends Resource
class_name Spell

@export var name: String
@export var description: String
@export var cost: int
@export var damage: int

func execute(user: Character, target: Character) -> String:
    user.special_points -= cost
    var action_string = ""

    var final_damage = int(damage * (1 + user.special_attack / 100.0))
    
    action_string += ("You" if user is Player else user.name) + " hit " + ("you" if target is Player else target.name) + " for " + str(target.take_special_damage(final_damage)) + " damage!\n"

    return action_string
