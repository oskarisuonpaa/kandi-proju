class_name NoteItem
extends Item

@export_multiline var content := ""


func use(_target = null) -> String:
    return content
