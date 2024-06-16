class_name Item
extends Resource


@export var name:= "Item"
@export var description:= "An item that can be picked up and used."
@export var take_description_override:= ""


func take() -> String:
    if take_description_override != "":
        return take_description_override
    else:
        return "You take the " + name + "."


func use(_target = null):
    pass


func drop():
    pass


func look():
    return name + " -- " + description

