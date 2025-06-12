extends Node3D

const SPAWN_RANDOM := 5.0


# NOTE -> It might make more sense to place the player spawner in the World as
# opposed to having each level handle spawning players.
var preloaded_player = preload("res://scenes/characters/Player.tscn")
#var preloaded_player = preload("res://scenes/characters/ClientOwnedPlayer.tscn")

func _ready():
	# We only need to spawn players on the server.
	$PlayerSpawner.call_deferred("set_multiplayer_authority", 1)
	if multiplayer.is_server():
		_host_spawn_players()
		return


func _host_spawn_players() -> void:
	assert(multiplayer.is_server())
	multiplayer.peer_connected.connect(_host_add_player)
	multiplayer.peer_disconnected.connect(del_player)

	# Spawn already connected players
	var peers = multiplayer.get_peers()
	Logging.peer_print("Peers are %s" % peers)
	for id in multiplayer.get_peers():
		print("Adding already connected ", id)
		_host_add_player(id)

	# Spawn the local player unless this is a dedicated server export.
	if not OS.has_feature("dedicated_server"):
		var id = multiplayer.get_unique_id()
		_host_add_player(id)

func _exit_tree():
	if multiplayer.is_server():
		multiplayer.peer_connected.disconnect(_host_add_player)
		multiplayer.peer_disconnected.disconnect(del_player)


func _host_add_player(id: int):
	assert(multiplayer.is_server())
	Logging.peer_print("Host is Adding player to default level: %s" % id)
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
	var player = $Players.get_node(str(id))
	player.queue_free()
	#Server.stop_tracking_player(player)
