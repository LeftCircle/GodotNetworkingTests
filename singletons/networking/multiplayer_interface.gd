extends Node
class_name MultiplayerInterface

signal game_start()

# Both classes have a multiplayer_peer variable, but the types are different
# se we are keeping that in the child classes
#var multiplayer_scene
#var _players_spawn_node

func ready() -> void:
	pass

func become_host() -> void:
	pass

func join_as_client(lobby_id) -> void:
	pass

## Adding and removing players is handled by the level
func _add_player_to_game(id: int) -> void:
	assert(multiplayer.get_unique_id() == 1)
	Logging.peer_print("Player %s joined the game!" % id)

# Adding and removing players is handled by the level
func _del_player(id: int) -> void:
	Logging.peer_print("Player %s left the game!" % id)
