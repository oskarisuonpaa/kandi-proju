class_name HealingItem
extends Item

@export var amount: int

func use(target: Character = null) -> void:
    if target:
        target.heal(amount)
