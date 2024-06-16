class_name EventManager
extends Node

signal event_started(event: Event)
signal event_ended()
signal response_generated(response: String, delay: float)

@onready var player: Player = $"../PlayerManager".get_player()
@onready var location_manager: LocationManager = $"../LocationManager"

var current_event: Event = null
var should_end_game := false

func start_event(event: Event) -> void:
    _connect_event_signals(event)
    event_started.emit(event)
    current_event = event
    event.begin_event()


func end_event() -> void:
    if current_event:
        _disconnect_event_signals(current_event)
        current_event.end_event()
        event_ended.emit()
        current_event = null


func is_input_required() -> bool:
    if current_event:
        return current_event.input_required
    return false


func _set_player() -> void:
    if current_event:
        current_event.set_player(player)


func _connect_event_signals(event: Event) -> void:
    event.ended.connect(_on_event_ended)
    event.response_generated.connect(_on_response_generated)
    event.should_end_game.connect(_on_should_end_game)
    event.items_given.connect(_on_items_given)
    event.request_player.connect(_on_request_player)
    event.location_changed.connect(_on_location_changed)


func _disconnect_event_signals(event: Event) -> void:
    event.ended.disconnect(_on_event_ended)
    event.response_generated.disconnect(_on_response_generated)
    event.should_end_game.disconnect(_on_should_end_game)
    event.items_given.disconnect(_on_items_given)
    event.request_player.disconnect(_on_request_player)
    event.location_changed.disconnect(_on_location_changed)


func _on_event_ended(event: Event) -> void:
    if event:
        end_event()
        start_event(event)
    else:
        end_event()


func _on_response_generated(response: String, delay: float) -> void:
    response_generated.emit(response, delay)


func _on_should_end_game() -> void:
    should_end_game = true


func _on_items_given(items: Array) -> void:
    player.add_items(items)


func _on_request_player() -> void:
    _set_player()


func _on_location_changed(location: String) -> void:
    location_manager.event_location_change(load(location))
