extends Resource
class_name Event

signal ended(event: Event)
signal response_generated(response: String, delay: float)
signal items_given(items: Array)
signal should_end_game()
signal request_player()
signal location_changed(location: String)

@export var steps = []
var input_required = false
var player: Player

func begin_event():
    pass


func end_event(event: Event = null):
    ended.emit(event)


func set_player(player_: Player):
    self.player = player_
