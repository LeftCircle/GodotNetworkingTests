extends Node

signal game_start()

enum MULTIPLAYER_NETWORK_TYPE { ENET, STEAM }

#@export var _players_spawn_node: Node3D
@export var active_network_type: MULTIPLAYER_NETWORK_TYPE = MULTIPLAYER_NETWORK_TYPE.ENET


var enet_network_scene := preload("res://singletons/networking/scenes/EnetMultipalyer.tscn")
var steam_network_scene := preload("res://singletons/networking/scenes/SteamMultiplayer.tscn")
var active_network

func _build_multiplayer_network():
	if not active_network:
		print("Setting active_network")

		match active_network_type:
			MULTIPLAYER_NETWORK_TYPE.ENET:
				print("Setting network type to ENet")
				_set_active_network(enet_network_scene)
				SteamManager.queue_free()
			MULTIPLAYER_NETWORK_TYPE.STEAM:
				print("Setting network type to Steam")
				_set_active_network(steam_network_scene)
			_:
				print("No match for network type!")

func _set_active_network(active_network_scene):
	var network_scene_initialized = active_network_scene.instantiate()
	active_network = network_scene_initialized
	#active_network._players_spawn_node = _players_spawn_node
	add_child(active_network)
	active_network.game_start.connect(_on_game_start.bind())

func become_host(is_dedicated_server = false):
	_build_multiplayer_network()
	active_network.become_host()

func join_as_client(lobby_id = 0):
	_build_multiplayer_network()
	active_network.join_as_client(lobby_id)

func list_lobbies():
	_build_multiplayer_network()
	active_network.list_lobbies()

func _on_game_start() -> void:
	game_start.emit()
