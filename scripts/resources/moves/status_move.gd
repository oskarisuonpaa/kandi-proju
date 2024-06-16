class_name StatusMove
extends Move

@export var effect: StatusEffect = null
@export var duration := 1

func execute(_user: Character, target: Character) -> String:
    target.add_status_effect(effect, duration)
    return effect.name + " was applied to " + (target.name if target is Enemy else "you") + "!"

