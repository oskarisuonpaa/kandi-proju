extends Control

const InputHistory = preload("res://scenes/input_history.tscn")
const Response = preload("res://scenes/response.tscn")

@export var history_limit := 30
@export var starting_floor := "floor1"

@onready var location_manager: LocationManager = $LocationManager
@onready var input_manager: InputManager = $InputManager
@onready var player_manager: PlayerManager = $PlayerManager
@onready var event_manager: EventManager = $EventManager
@onready var history_rows: VBoxContainer = $Background/Margin/Rows/GameInfo/Scroll/Margin/HistoryRows
@onready var history_scroll: ScrollContainer = $Background/Margin/Rows/GameInfo/Scroll
@onready var history_scrollbar: ScrollBar = history_scroll.get_v_scroll_bar()

var input_response_queue := []
var time_stamp := 0.0

func _ready() -> void:
    input_manager.input_generated.connect(_on_input_generated)
    input_manager.response_generated.connect(_on_response_generated)

    event_manager.response_generated.connect(_on_response_generated)
    location_manager.response_generated.connect(_on_response_generated)
    player_manager.response_generated.connect(_on_response_generated)

    history_scrollbar.changed.connect(_on_scrollbar_changed)

    location_manager.initialize(starting_floor)


func _process(delta: float) -> void:
    if input_response_queue:
        time_stamp -= delta
        if time_stamp <= 0:
            var input_response = input_response_queue.pop_front()
            history_rows.add_child(input_response["text"])
            _delete_history_beyond_limit()
            time_stamp = input_response["delay"]


func _on_input_generated(input: String) -> void:
    var input_history = InputHistory.instantiate()
    input_history.text = " > " + input
    input_response_queue.append({"text": input_history, "delay": 0.0})


func _on_response_generated(response: String, delay: float) -> void:
    if response == "":
        return
        
    var response_scene = Response.instantiate()
    response_scene.text = response
    input_response_queue.append({"text": response_scene, "delay": delay})


func _on_scrollbar_changed() -> void:
    history_scroll.scroll_vertical = int(history_scrollbar.max_value)


func _delete_history_beyond_limit() -> void:
    if history_rows.get_child_count() > history_limit:
        var rows_to_forget = history_rows.get_child_count() - history_limit
	
        for i in range(rows_to_forget):
            history_rows.get_child(i).queue_free()


