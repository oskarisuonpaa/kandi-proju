class_name AggressiveMove
extends Move

@export var damage := 10
@export_range(0,100) var critical_chance := 10
@export var critical_multiplier := 2
@export_range(0,5) var repeat := 1

func execute(user : Character, target : Character) -> String:
    action_points -= 1
    var action_string = ""

    for i in range(repeat):
        if randi() % 100 < chance:
            var final_move_damage = damage * (1 + user.calculate_final_attack() / 100.0)
            if randi() % 100 < critical_chance:
                final_move_damage *= critical_multiplier
                action_string += "Critical hit!\n"
            
            action_string += ("You" if user is Player else user.name) + " hit " + ("you" if target is Player else target.name) + " for " + str(target.take_damage(final_move_damage)) + " damage!\n"
        else:
            action_string += "Miss!\n"

    return action_string
