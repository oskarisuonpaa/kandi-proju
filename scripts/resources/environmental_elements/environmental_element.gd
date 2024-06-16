extends Resource
class_name EnvironmentalElement

@export var name = ""
@export_multiline var description = ""

func look() -> String:
    return description


func interact():
    return "You can't interact with this object."


func take():
    return "You can't take this object."
