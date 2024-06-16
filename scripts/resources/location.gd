extends Resource
class_name Location

signal response_generated(response: String, delay: float)
signal event_began(event: Event)

@export var name: String = ""
@export_multiline var description: String = ""
@export var connections: Dictionary = {}
@export var environment = []
@export var hidden_items = []
@export var items = []
@export var events : Dictionary = {}

var exits: Dictionary = {}

func on_enter():
    if events.has("ON_ENTER"):
        _trigger_event("ON_ENTER")
    else:
        look()


func on_exit():
    if events.has("ON_EXIT"):
        _trigger_event("ON_EXIT")
    else:
        pass


func on_wait():
    if events.has("ON_WAIT"):
        for event in events["ON_WAIT"]:
            if randf() < event["chance"]:
                _start_event(event["event"])
                break
    else:
        response_generated.emit("You wait.", 0.0)


func look():
    response_generated.emit(TextWrapper.location_text(name), 0.0)
    response_generated.emit(get_full_description(), 0.0)


func get_full_description() -> String:
    var description_string = PackedStringArray([
        description,
    ])

    if items.size() > 0:
        description_string.push_back(_get_items_string())

    if exits.size() > 0:
        description_string.push_back(_get_exits_string())

    return ("\n").join(description_string)


func _get_items_string() -> String:
    var items_string = PackedStringArray()

    for item in items:
        items_string.push_back(item.name)

    return "Items: " + (", ").join(items_string)


func _get_exits_string() -> String:
    var exits_string = "Exits: "
    exits_string += (", ").join(exits.keys())

    return exits_string


func connect_exit(exit_name: String, location: Location) -> void:
    var exit = Exit.new()
    exit.location1 = self
    exit.location2 = location
    exits[exit_name] = exit

    match exit_name:
        "north":
            location.exits["south"] = exit
        "south":
            location.exits["north"] = exit
        "east":
            location.exits["west"] = exit
        "west":
            location.exits["east"] = exit
        "up":
            location.exits["down"] = exit
        "down":
            location.exits["up"] = exit
        _:
            location.exits[exit_name] = exit


func _trigger_event(event_key: String) -> void:
    if events.has(event_key):
        _start_event(events[event_key])
        events[event_key] = null


func _start_event(event: Event) -> void:
    event_began.emit(event)

