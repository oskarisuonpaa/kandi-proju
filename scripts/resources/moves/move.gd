class_name  Move
extends Resource

@export var name := "Move"
@export var description := "Description of the move."
@export_range(0,100) var chance := 100
@export var max_action_points := 1:
    set(value):
        max_action_points = value
        action_points = value

var action_points := 1


func execute(_user : Character, _target : Character) -> String:
    return "Move executed"
