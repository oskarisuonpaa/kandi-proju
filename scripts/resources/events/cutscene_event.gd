extends Event
class_name CutsceneEvent

@export var paths: Dictionary = {}

var current_step = 0

func begin_event():
    super.begin_event()
    request_player.emit()
    _execute_step()


func end_event(event: Event = null):
    super.end_event(event)


func _execute_step():
    input_required = false

    if current_step >= steps.size():
        end_event()
        return
    match steps[current_step].type:
        "narration":
            _narration()
        "input":
            _input()
        "dialogue":
            _dialogue()
        "choice":
            _choice()
        "end":
            _end()
        "gift":
            _gift()
        "location_change":
            _location_change()
        "heal":
            _heal()
        _:
            printerr("Invalid step type: " + steps[current_step].type)


func _narration():
    var step = steps[current_step]
    var text = step.text
    var delay = 0.0
    if step.keys().has("delay"):
        delay = step.delay

    response_generated.emit(text, delay)
    current_step += 1
    _execute_step()


func _input():
    input_required = true


func _dialogue():
    var step = steps[current_step]
    var speaker = step.speaker
    var text = step.text
    var delay = 2.0
    if step.keys().has("delay"):
        delay = step.delay

    response_generated.emit(TextWrapper.npc_text(speaker + ": ") + TextWrapper.speech_text(text), delay)
    current_step += 1
    _execute_step()


func _choice() -> void:
    input_required = true


func handle_input(command: String, args: Array) -> void:
    var step = steps[current_step]

    if step.type == "input":
        _input_command(command, args)
    elif step.type == "choice":
        _choice_command(command, args)


func _input_command(command: String, args: Array) -> void:
    var step = steps[current_step]
    var delay = 0.0
    if step.keys().has("delay"):
        delay = step.delay

    if step.commands.size() == 0:
        response_generated.emit(TextWrapper.system_text(step.wrong_input), delay)
        return
    for event_command in step.commands:
        if command == event_command.command:
            if event_command.args.size() == 0:
                response_generated.emit(event_command.response, delay)
                current_step += 1
                _execute_step()
                return
            if event_command.args.size() == args.size():
                var is_match = true
                for i in range(args.size()):
                    if args[i] != event_command.args[i]:
                        is_match = false
                        break
                if is_match:
                    response_generated.emit(event_command.response, delay)
                    current_step += 1
                    _execute_step()
                    return
        
    response_generated.emit(TextWrapper.system_text(step.wrong_input), delay)


func _choice_command(command: String, args: Array) -> void:
    var step = steps[current_step]
    var delay = 0.0
    if step.keys().has("delay"):
        delay = step.delay

    if args.size() != 0 and args[0] != "":
        response_generated.emit(TextWrapper.system_text(step.wrong_input), delay)
        return
    
    for choice in step.choices:
        if choice.command == command:
            _switch_path(choice.path)
            return
    
    response_generated.emit(TextWrapper.system_text(step.wrong_input), delay)


func _switch_path(path: String) -> void:
    if paths.has(path):
        steps = paths[path]
        current_step = 0
        _execute_step()
    else:
        printerr("Path not found: " + path)


func _end():
    var step = steps[current_step]
    var delay = 0.0
    if step.keys().has("delay"):
        delay = step.delay

    if step.variant == "bad":
        response_generated.emit(TextWrapper.bad_ending_text("Bad ending: " + step.text), delay)
        should_end_game.emit()


func _gift():
    var step = steps[current_step]
    var gift = load(step.gift)

    items_given.emit([gift])
    current_step += 1
    _execute_step()


func _location_change():
    var step = steps[current_step]
    var location = step.location

    location_changed.emit(location)
    current_step += 1
    _execute_step()


func _heal():
    player.heal(player.max_health)
    current_step += 1
    _execute_step()
