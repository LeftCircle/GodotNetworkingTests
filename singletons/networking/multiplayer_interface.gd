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

# Adding and removing players is handled by the level
func _add_player_to_game(id: int) -> void:
	print("Player %s joined the game!" % id)

	#var player_to_add = multiplayer_scene.instantiate()
	#player_to_add.player_id = id
	#player_to_add.name = str(id)

	#_players_spawn_node.add_child(player_to_add, true)

# Adding and removing players is handled by the level
func _del_player(id: int) -> void:
	print("Player %s left the game!" % id)
	#if not _players_spawn_node.has_node(str(id)):
	#	return
	#_players_spawn_node.get_node(str(id)).queue_free()
