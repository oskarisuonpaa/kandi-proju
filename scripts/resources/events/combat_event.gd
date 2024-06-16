class_name CombatEvent
extends Event

@export var enemy: Enemy
@export var on_player_death: Event
@export var on_enemy_death: Event
@export var can_run:= false

var enemy_turn_handled = false
var player_turn_handled = false

func begin_event():
    request_player.emit()


func set_player(player_: Player) -> void:
    super.set_player(player_)
    response_generated.emit("You have encountered " + enemy.name + "!", 0.0)
    _decide_turn_order()


func _decide_turn_order() -> void:
    player_turn_handled = false
    enemy_turn_handled = false

    if player.speed > enemy.speed:
        _player_turn()
    elif player.speed < enemy.speed:
        _enemy_turn()
    else:
        if randf() < 0.5:
            _player_turn()
        else:
            _enemy_turn()


func _check_turns() -> void:
    if player_turn_handled and enemy_turn_handled:
        response_generated.emit(TextWrapper.player_combat_text(player.process_status_effects()), 0.0)
        response_generated.emit(TextWrapper.enemy_combat_text(enemy.process_status_effects()), 0.0)

        if player.health <= 0:
            _handle_player_death()
        elif enemy.health <= 0:
            _handle_enemy_death()
        else:
            _decide_turn_order()
    elif player_turn_handled:
        _enemy_turn()
    elif enemy_turn_handled:
        _player_turn()

## Player logic
func _player_turn() -> void:
    input_required = true
    response_generated.emit(TextWrapper.player_combat_text("What will you do?"), 0.0)


func handle_input(command: String, args: Array) -> void:
    if not input_required:
        return

    match command:
        "use":
            match args[0]:
                "item":
                    _player_use_item(args.slice(1))
                "move":
                    _player_attack(args.slice(1))
                _:
                    response_generated.emit(TextWrapper.system_text("Invalid keyword."), 0.0)
        "cast":
            _player_cast_spell(args)
        "run":
            _player_run()
        "moves":
            _player_moves()
        "look":
            _look(args)
        "spells":
            _player_spells()
        "inventory":
            _player_inventory()
        "help":
            _help()
        _:
            response_generated.emit(TextWrapper.system_text("Invalid command. Please choose 'attack', 'spell', 'item', or 'run'."), 0.0)


func _help() -> void:
    var help_string = PackedStringArray([
        "Commands:",
        "use item [item name] - Use an item from your inventory.",
        "use move [move name] - Use a move.",
        "cast [spell name] - Cast a spell from your spellbook.",
        "run - Attempt to run away from the enemy.",
        "moves - Display your available moves.",
        "look [target] - Look at the enemy or yourself.",
        "spells - Display your available spells.",
        "inventory - Display your inventory."
    ])

    response_generated.emit(TextWrapper.system_text("\n".join(help_string)), 0.0)


func _player_turn_handled() -> void:
    player_turn_handled = true
    input_required = false
    _check_turns()


func _player_use_item(args: Array) -> void:
    if args.size() == 0:
        response_generated.emit(TextWrapper.system_text("Use what?"), 0.0)
        return
    
    if player.inventory.size() == 0:
        response_generated.emit(TextWrapper.system_text("You have no items to use!"), 0.0)
        return

    for item in player.inventory.values():
        if _matches_object(args, item.item.name):
            if !item.item is HealingItem:
                response_generated.emit(TextWrapper.system_text("You cannot use that item in combat."), 0.0)
                return
            
            item.item.use(player)
            item.amount -= 1

            if item.amount <= 0:
                player.remove_item(item.item.name)

            response_generated.emit(TextWrapper.player_combat_text("You used " + item.item.name + "."), 0.0)
            response_generated.emit(TextWrapper.player_combat_text("You have " + str(player.health) + "/" + str(player.max_health) + " health remaining."), 0.0)
            
            _player_turn_handled()
            return
    
    response_generated.emit(TextWrapper.system_text("You do not have that item."), 0.0)


func _player_attack(args: Array) -> void:
    if args.size() == 0:
        response_generated.emit(TextWrapper.system_text("Use what?"), 0.0)
        _player_turn_handled()
        return
    
    for move in player.core.moves:
        if _matches_object(args, move.name):
            if move.action_points == 0:
                response_generated.emit(TextWrapper.system_text("You have exhausted that move!"), 0.0)
            else:
                response_generated.emit(TextWrapper.player_combat_text(move.execute(player, enemy)), 0.0)
                response_generated.emit(TextWrapper.enemy_combat_text(enemy.name + " has " + str(enemy.health) + "/" + str(enemy.max_health) + " health remaining."), 0.0)

                if enemy.health <= 0:
                    _handle_enemy_death()
                else:
                    _player_turn_handled()

                return
            
    response_generated.emit(TextWrapper.system_text("You do not have that move."), 0.0)


func _player_cast_spell(args: Array) -> void:
    if args.size() == 0:
        response_generated.emit(TextWrapper.system_text("Cast what?"), 0.0)
        return

    if player.spells.size() == 0 and player.core.spells.size() == 0:
        response_generated.emit(TextWrapper.system_text("You have no spells to cast!"), 0.0)
        return
    
    if player.core.special_points == 0:
        response_generated.emit(TextWrapper.system_text("You have no special points!"), 0.0)
        return

    for spell in player.spells.keys():
        if _matches_object(args, spell):
            if player.spells[spell].cost > player.core.special_points:
                response_generated.emit(TextWrapper.system_text("You do not have enough special points!"), 0.0)
                return
            
            response_generated.emit(TextWrapper.player_combat_text("You casted " + spell + "!"), 0.0)
            response_generated.emit(TextWrapper.player_combat_text(player.spells[spell].execute(player, enemy)), 0.0)
            response_generated.emit(TextWrapper.enemy_combat_text(enemy.name + " has " + str(enemy.health) + "/" + str(enemy.max_health) + " health remaining."), 0.0)

            if enemy.health <= 0:
                _handle_enemy_death()
            else:
                _player_turn_handled()

            return

    response_generated.emit(TextWrapper.system_text("You do not have that spell!"), 0.0)
    _player_turn_handled()


func _player_run() -> void:
    if can_run and randf() < 0.3:
        response_generated.emit("You run away!", 0.0)
        end_event()
    else:
        response_generated.emit(TextWrapper.system_text("You can't run away!"), 0.0)
        _player_turn_handled()


func _player_moves() -> void:
    var moves_string = TextWrapper.system_text("Moves:\n")

    for move in player.moves:
        moves_string += move.name + "(" + str(move.action_points) + "/" + str(move.max_action_points) + ")- " + move.description + "\n"

    response_generated.emit(moves_string, 0.0)


func _look(args: Array) -> void:
    if args.size() == 0:
        response_generated.emit(TextWrapper.system_text("Look at what?"), 0.0)
        return
    
    if args.size() == 1:
        if args[0] == "enemy":
            response_generated.emit(TextWrapper.enemy_combat_text(enemy.look()), 0.0)
        elif args[0] == "self":
            response_generated.emit(TextWrapper.player_combat_text(player.look()), 0.0)
        else:
            response_generated.emit(TextWrapper.system_text("Invalid target."), 0.0)


func _handle_player_death() -> void:
    if on_player_death:
        ended.emit(on_player_death)
    else:
        response_generated.emit("You have died!", 0.0)
        should_end_game.emit()
        end_event()

    
func _player_spells() -> void:
    var spells_string = TextWrapper.system_text("Spells:\n")

    for spell in player.spells.keys():
        spells_string += spell + " - " + player.spells[spell].description + "\n"

    response_generated.emit(spells_string, 0.0)


func _player_inventory() -> void:
    var inventory_string = TextWrapper.system_text("Inventory:\n")

    for item in player.inventory.values():
        inventory_string += item.item.name + " - " + item.item.description + "\n"

    response_generated.emit(inventory_string, 0.0)

## Enemy logic
func _enemy_turn() -> void:
    response_generated.emit(TextWrapper.enemy_combat_text(enemy.name + "'s turn!"), 0.0)

    if _should_struggle():
        response_generated.emit(TextWrapper.enemy_combat_text(enemy.name + " struggles!"), 0.0)
        _enemy_turn_handled()
        return

    _decide_action()


func _should_struggle() -> bool:
    for move in enemy.moves:
        if move.action_points > 0:
            return false
    for spell in enemy.spells:
        if spell.cost <= enemy.special_points:
            return false
    return true

func _enemy_turn_handled() -> void:
    enemy_turn_handled = true
    _check_turns()


func _decide_action() -> void:
    if enemy.special_points >= 1 and randf() < 0.3 and enemy.spells.size() > 0:
        _enemy_use_special()
    else:
        _enemy_use_move()


func _enemy_use_special(repeat = 0) -> void:
    var spell = enemy.spells[randi() % enemy.spells.size()]

    if spell.cost <= enemy.special_points:
        response_generated.emit(TextWrapper.enemy_combat_text(enemy.name + " casts " + spell.name + "!"), 0.0)
        spell.execute(enemy, player)
        response_generated.emit(TextWrapper.player_combat_text("You have " + str(player.health) + "/" + str(player.max_health) + " health remaining."), 0.0)
        
        if player.health <= 0:
            _handle_player_death()
        else:
            _enemy_turn_handled()
        
        return
        
    if repeat < 3:
        if randf() < 0.7:
            _enemy_use_move(repeat + 1)
        else:
            _enemy_use_special(repeat + 1)
    else:
        response_generated.emit(TextWrapper.enemy_combat_text(enemy.name + " struggles!"), 0.0)
        _enemy_turn_handled()


func _enemy_use_move(repeat = 0) -> void:
    var move = enemy.moves[randi() % enemy.moves.size()]

    if move.action_points > 0:
        response_generated.emit(TextWrapper.enemy_combat_text(enemy.name + " uses " + move.name + "!"), 0.0)
        if randf() < move.chance:
            if move is AggressiveMove:
                response_generated.emit(TextWrapper.enemy_combat_text(move.execute(enemy, player)), 0.0)
                response_generated.emit(TextWrapper.player_combat_text("You have " + str(player.health) + "/" + str(player.max_health) + " health remaining."), 0.0)
            elif move is BuffMove:
                response_generated.emit(TextWrapper.enemy_combat_text(move.execute(enemy, enemy)), 0.0)
            elif move is DebuffMove:
                response_generated.emit(TextWrapper.enemy_combat_text(move.execute(enemy, player)), 0.0)
            else:
                response_generated.emit(TextWrapper.enemy_combat_text(enemy.name + " missed!"), 0.0)
        
        if player.health <= 0:
            _handle_player_death()
        else:
            _enemy_turn_handled()
        
        return
    
    if repeat < 3:
        _enemy_use_move(repeat + 1)
    else:
        response_generated.emit(TextWrapper.enemy_combat_text(enemy.name + " struggles!"), 0.0)
        _enemy_turn_handled()


func _handle_enemy_death() -> void:
    if on_enemy_death:
        ended.emit(on_enemy_death)
    else:
        response_generated.emit("You have defeated " + enemy.name + "!", 0.0)
        player.gain_experience(enemy.experience_drop)
        player.add_items(enemy.drop_loot())
        end_event()


func _matches_object(object: Array, target: String) -> bool:
    var target_words = target.to_lower().split(" ")
    var object_str = " ".join(object).to_lower()

    if object_str in target:
        return true
    elif len(object) == 1 and object[0].to_lower() in target_words:
        return true
    else:
        return false
