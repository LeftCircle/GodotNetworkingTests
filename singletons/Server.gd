extends Node
const PORT = 4433
var default_ip = "127.0.0.1"

# This server singleton is present on both the host and clients. It's a very
# convienent place to put @rpc calls because you don't have to worry about
# the scene tree hierarchy and whether or not an @rpc call is present. It acts
# as the core place of communication between the host and the clients when it
# comes to establishing connections/starting the game/changing scenes.

signal player_connected(network_id)
signal player_disconnected(network_id)


func _ready():
	#get_tree().paused = true
	# You can save bandwidth by disabling server relay and peer notifications.
	#multiplayer.server_relay = false

	# Automatically start the server in headless mode.
	if DisplayServer.get_name() == "headless":
		print("Automatically starting dedicated server.")
		on_host_pressed.call_deferred()

func on_host_pressed():
	# Start as server.
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server.")
		return
	multiplayer.multiplayer_peer = peer
	_hook_up_connection_signals()
	start_game()


func on_connect_pressed():
	# Start as client.
	var txt : String = $UI/Net/Options/Remote.text
	var ip : String
	if txt == "":
		#OS.alert("Need a remote to connect to.")
		print("Connecting to default ip", default_ip)
		ip = default_ip
	else:
		ip = txt
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client.")
		return
	multiplayer.multiplayer_peer = peer
	start_game()

func _hook_up_connection_signals() -> void:
	# We only need to spawn players on the server.
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.connect(_on_player_connected_to_host)
	multiplayer.peer_disconnected.connect(_on_player_disconnected_from_host)

func _on_player_connected_to_host(id : int) -> void:
	player_connected.emit(id)

func _on_player_disconnected_from_host(id : int) -> void:
	player_disconnected.emit(id)

func start_game():
	# Hide the UI and unpause to start the game.
	$UI.hide()
	get_tree().paused = false
	# Only change level on the server.
	# Clients will instantiate the level via the spawner.
	if multiplayer.is_server():
		World.change_level.call_deferred(load(World.starting_level_path))
