extends Node

const COLOR_SYSTEM = Color("#ADD8E6")
const COLOR_LOCATION = Color("#FFB700")
const COLOR_NPC = Color("#80C98E")
const COLOR_SPEECH = Color("#B19CD9")
const COLOR_BAD_ENDING = Color("#D63220")
const COLOR_PLAYER_COMBAT = Color("#00FF00")
const COLOR_ENEMY_COMBAT = Color("#FF0000")

func system_text(text: String) -> String:
    return "[color=" + COLOR_SYSTEM.to_html() + "]" + text + "[/color]"


func location_text(text: String) -> String:
    return "[color=" + COLOR_LOCATION.to_html() + "]" + text + "[/color]"


func npc_text(text: String) -> String:
    return "[color=" + COLOR_NPC.to_html() + "]" + text + "[/color]"


func speech_text(text: String) -> String:
    return "[color=" + COLOR_SPEECH.to_html() + "]" + text + "[/color]"


func bad_ending_text(text: String) -> String:
    return "[color=" + COLOR_BAD_ENDING.to_html() + "]" + text + "[/color]"


func player_combat_text(text: String) -> String:
    return "[color=" + COLOR_PLAYER_COMBAT.to_html() + "]" + text + "[/color]"


func enemy_combat_text(text: String) -> String:
    return "[color=" + COLOR_ENEMY_COMBAT.to_html() + "]" + text + "[/color]"
