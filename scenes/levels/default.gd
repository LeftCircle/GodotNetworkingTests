extends Node3D

const SPAWN_RANDOM := 5.0


# NOTE -> It might make more sense to place the player spawner in the World as
# opposed to having each level handle spawning players.
var preloaded_player = preload("res://scenes/characters/Player.tscn")

func _ready():
	# We only need to spawn players on the server.
	if not multiplayer.is_server():
		return
	_spawn_players()


func _spawn_players() -> void:
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)

	# Spawn already connected players
	for id in multiplayer.get_peers():
		print("Adding already connected ", id)
		add_player(id)

	# Spawn the local player unless this is a dedicated server export.
	if not OS.has_feature("dedicated_server"):
		var id = multiplayer.get_unique_id()
		add_player(id)

func _exit_tree():
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(del_player)


func add_player(id: int):
	print("Adding player to default level: ", id)
	var character = preloaded_player.instantiate()
	# Set player id.
	character.player = id
	# Randomize character position.
	var pos := Vector2.from_angle(randf() * 2 * PI)
	character.position = Vector3(pos.x * SPAWN_RANDOM * randf(), 0, pos.y * SPAWN_RANDOM * randf())
	character.name = str(id)
	$Players.add_child(character, true)


func del_player(id: int):
	if not $Players.has_node(str(id)):
		return
	$Players.get_node(str(id)).queue_free()
