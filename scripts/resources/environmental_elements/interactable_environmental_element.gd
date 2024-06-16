extends EnvironmentalElement
class_name InteractableEnvironmentElement


signal event_began(event: Event)

@export var interaction_event: Event = null


func interact():
    if interaction_event != null:
        event_began.emit(interaction_event)
    else:
        super.interact()


func take() -> String:
    if interaction_event != null:
        event_began.emit(interaction_event)
        return ""
    else:
        var string = super.take()
        return string
