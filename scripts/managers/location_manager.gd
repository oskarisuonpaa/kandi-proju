class_name LocationManager
extends Node

signal response_generated(response: String, delay: float)

@onready var event_manager: EventManager = $"../EventManager"

var current_floor: Floor = null
var current_location: Location = null
var previous_location: Location = null

func initialize(starting_floor: String) -> void:
	current_floor = load("res://resources/floors/" + starting_floor + ".tres")
	
	for location in current_floor.locations:
		_connect_location_exits(location)
	
	current_location = current_floor.entry_location
	_connect_signals(current_location)
	current_location.on_enter()
	
	
func _connect_location_exits(location: Location) -> void:
	for connection in location.connections:
		location.connect_exit(connection, location.connections[connection])


func change_location(direction: String) -> void:
	var new_location = null

	if current_location.exits.has(direction):
		new_location = current_location.exits[direction].get_other_location(current_location)
	else:
		response_generated.emit(TextWrapper.system_text("You can't go that way."), 0.0)
		return

	if current_location != null:
		_disconnect_signals(current_location)
		current_location.on_exit()
		previous_location = current_location
	
	current_location = new_location
	_connect_signals(current_location)
	current_location.on_enter()


func _change_location(location: Location) -> void:
	if current_location != null:
		_disconnect_signals(current_location)
		current_location.on_exit()
		previous_location = current_location
	
	current_location = location
	_connect_signals(current_location)
	current_location.on_enter()

func get_environment():
	return current_location.environment


func get_items():
	return current_location.items


func get_hidden_items():
	return current_location.hidden_items


func back():
	if previous_location != null:
		_change_location(previous_location)
	else:
		response_generated.emit(TextWrapper.system_text("You can't go back."), 0.0)


func add_item(item: Item) -> void:
	current_location.items.append(item)


func remove_item(item: Item) -> void:
	current_location.items.erase(item)


func get_item(args: Array) -> Item:
	for item in get_items():
		if _matches_object(args, item.name):
			return item
	return null


func get_hidden_item(args: Array) -> Item:
	for item in get_hidden_items():
		if _matches_object(args, item.name):
			return item
	return null


func get_environmental_element(args: Array) -> EnvironmentalElement:
	for element in current_location.environment:
		if _matches_object(args, element.name):
			return element
	return null


func look() -> void:
	current_location.look()


func _connect_signals(location: Location) -> void:
	location.response_generated.connect(_on_response_generated)
	location.event_began.connect(_on_event_began)


func _disconnect_signals(location: Location) -> void:
	location.response_generated.disconnect(_on_response_generated)
	location.event_began.disconnect(_on_event_began)


func _on_response_generated(response: String, delay: float) -> void:
	response_generated.emit(response, delay)


func _on_event_began(event: Event) -> void:
	event_manager.start_event(event)


func event_location_change(location: Location) -> void:
	_change_location(location)
	previous_location = null


func wait() -> void:
	current_location.on_wait()

## Object is the inputted object to search and target is the objects name
func _matches_object(object: Array, target: String) -> bool:
	var target_words = target.split(" ")

	if " ".join(object) in target and len(object) == len(target_words):
		return true
	elif len(object) == 1 and object[0] in target_words:
		return true
	else:
		return false


