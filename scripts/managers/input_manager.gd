class_name InputManager
extends Node

signal input_generated(input: String)
signal response_generated(response: String, delay: float)

@onready var event_manager = $"../EventManager"
@onready var player_manager = $"../PlayerManager"
@onready var location_manager = $"../LocationManager"

func change_location(new_location: Location) -> void:
    location_manager.change_location(new_location)


func _on_input_text_submitted(new_text: String) -> void:
    if new_text == "":
        return
    
    _parse_input(new_text)


func _on_response_generated(response: String, delay: float) -> void:
    response_generated.emit(response, delay)


func _parse_input(input: String) -> void:
    var words = input.to_lower().split(" ")
    var command = words[0]
    var args = words.slice(1)

    input_generated.emit(input)
    _process_input(command, args)


func _process_input(command: String, args: Array) -> void:
    if args.size() == 0:
        args.append("")

    if event_manager.should_end_game:
        handle_game_ended(command)
        return
    
    if event_manager.current_event:
        if event_manager.is_input_required():
            handle_active_event(command, args)
        return

    match command:
        "help":
            _help()
        "go":
            _go(args)
        "look":
            _look(args)
        "return":
            _return()
        "take":
            _take(args)
        "drop":
            _drop(args)
        "inventory":
            _inventory()
        "spells":
            _spells()
        "quit":
            _quit()
        "interact":
            _interact(args)
        "transform":
            _transform(args)
        "cores":
            _cores()
        "use":
            _use(args)
        "wait":
            _wait()
        "cast":
            _emit_response("Not implemented!")
        _:
            _emit_response("Invalid command. Type 'help' for a list of commands.")


func handle_game_ended(command: String) -> void:
    if command != "quit":
        _emit_response("The game has ended. Type 'quit' to exit.")
    else:
        _quit()


func handle_active_event(command: String, args: Array) -> void:
    if event_manager.current_event is CutsceneEvent or event_manager.current_event is CombatEvent:
        event_manager.current_event.handle_input(command, args)

func _emit_response(message: String, delay: float = 0) -> void:
    response_generated.emit(TextWrapper.system_text(message), delay)


func _help() -> void:
    var help_string = PackedStringArray([
        "Commands:",
        "help - Display this help message.",
        "go [direction] - Move in a specified direction.",
        "look [object] - Look at an object or the environment.",
        "return - Return to the previous location.",
        "take [object] - Take an object from the environment.",
        "drop [object] - Drop an object from your inventory.",
        "inventory - Display your inventory.",
        "spells - Display your spells.",
        "quit - Quit the game.",
        "interact [object] - Interact with an object in the environment.",
        "transform [core] - Transform into a different core.",
        "cores - Display your cores.",
        "use [item] - Use an item from your inventory.",
        "wait - Wait for a moment."
    ])

    _emit_response("\n".join(help_string))


func _go(args: Array) -> void:
    if args.size() == 0:
        _emit_response("You must specify a direction to go.")
        return

    if args.size() > 1:
        _emit_response("Too many arguments.")
        return
    
    location_manager.change_location(args[0])


func _look(args: Array) -> void:
    if args.size() == 1 and args[0] == "":
        location_manager.look()
        return

    if args[0] == "self":
        _emit_response(player_manager.look())
        return

    var environmental_element = location_manager.get_environmental_element(args)
    if environmental_element:
        _emit_response(environmental_element.description)
        return
    
    
    var item = location_manager.get_item(args)
    if item:
        _emit_response(item.description)
        return
    
    var hidden_item = location_manager.get_hidden_item(args)
    if hidden_item:
        _emit_response(hidden_item.description)
        return
    
    _emit_response("You don't see that here.")


func _return() -> void:
    location_manager.back()


func _take(args: Array) -> void:
    if args.size() == 1 and args[0] == "":
        _emit_response("You must specify an object to take.")
        return
    
    var environmental_element = location_manager.get_environmental_element(args)
    if environmental_element:
        if environmental_element is InteractableEnvironmentElement:
            environmental_element.event_began.connect(_start_event)
        
        var return_string = environmental_element.take()

        if return_string != "":
            _emit_response(return_string)

        if environmental_element is InteractableEnvironmentElement:
            environmental_element.event_began.disconnect(_start_event)
        return

    var item = location_manager.get_item(args)
    if item:
        player_manager.add_items([item])
        location_manager.current_location.items.erase(item)
        if item.take_description_override != "":
            _emit_response(item.take_description_override)
        else:
            _emit_response("You took " + item.name + ".")
        return
    

    var hidden_item = location_manager.get_hidden_item(args)
    if hidden_item:
        player_manager.add_items([hidden_item])
        location_manager.current_location.hidden_items.erase(hidden_item)
        if hidden_item.take_description_override != "":
            _emit_response(hidden_item.take_description_override)
        else:
            _emit_response("You took " + hidden_item.name + ".")
        return
    
    _emit_response("You don't see that here.")


func _drop(args: Array) -> void:
    if args.size() == 1 and args[0] == "":
        _emit_response("You must specify an object to drop.")
        return
    
    for item in player_manager.inventory.values():
        if _matches_object(args, item.item.name):
            player_manager.remove_item(item.item.name)
            location_manager.add_item(item.item)
            _emit_response("You dropped " + item.item.name + ".")
            return
    
    _emit_response("You don't have that item.")


func _inventory() -> void:
    _emit_response(player_manager.get_inventory_string())


func _spells() -> void:
    _emit_response(player_manager.get_spells_string())


func _quit() -> void:
    get_tree().quit()


func _interact(args: Array) -> void:
    var environmental_element = location_manager.get_environmental_element(args)
    if environmental_element:
        _emit_response(environmental_element.interact())
        return

    _emit_response("You don't see that here.")


func _transform(args: Array) -> void:
    if args.size() == 1 and args[0] == "":
        _emit_response("You must specify a transformation.")
        return
    
    player_manager.change_core(args)


func _cores() -> void:
    _emit_response(player_manager.get_cores_string())


func _use(args: Array) -> void:
    if args.size() == 1 and args[0] == "":
        _emit_response("You must specify an item to use.")
        return
    
    var item = player_manager.get_item(args)
    if item and item is HealingItem:
        item.use(player_manager.player)
        player_manager.remove_item(item.name)
        _emit_response("You used " + item.name + ".\nHP: " + str(player_manager.get_health()) + "/" + str(player_manager.get_max_health()))
        return
    elif item is NoteItem:
        _emit_response(item.use())
        return
        
    _emit_response("You don't have that item.")


func _wait() -> void:
    location_manager.wait()

func _matches_object(object: Array, target: String) -> bool:
    var target_words = target.split(" ")

    if " ".join(object) in target and len(object) == len(target_words):
        return true
    elif len(object) == 1 and object[0] in target_words:
        return true
    else:
        return false


func _start_event(event: Event) -> void:
    event_manager.start_event(event)
