class_name CoreItem
extends Item

@export var core: Core = null

func use(target: Player = null) -> void:
    if target:
        target.add_items([core])
    