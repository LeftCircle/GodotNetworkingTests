
# NOW USING NetworkManager!!!

#extends Node
#const PORT = 4433
##var default_ip = "127.0.0.1"
#var default_ip = "100.67.72.227"
#
## This server singleton is present on both the host and clients. It's a very
## convienent place to put @rpc calls because you don't have to worry about
## the scene tree hierarchy and whether or not an @rpc call is present. It acts
## as the core place of communication between the host and the clients when it
## comes to establishing connections/starting the game/changing scenes.
#
#signal player_connected(network_id)
#signal player_disconnected(network_id)
#signal game_start()
#
#var player_id_to_node = {}
#
#func _ready():
	##get_tree().paused = true
	## You can save bandwidth by disabling server relay and peer notifications.
	##multiplayer.server_relay = false
#
	## Automatically start the server in headless mode.
	#if DisplayServer.get_name() == "headless":
		#print("Automatically starting dedicated server.")
		#on_host_pressed.call_deferred()
#
#
#func on_host_pressed():
	## Start as server.
	#var peer = ENetMultiplayerPeer.new()
	#peer.create_server(PORT)
	#if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		#OS.alert("Failed to start multiplayer server.")
		#return
	#multiplayer.multiplayer_peer = peer
	#_hook_up_connection_signals()
	#start_game()
#
#
#func on_connect_pressed(ip : String = default_ip):
	## Start as client.
	#var peer = ENetMultiplayerPeer.new()
	#peer.create_client(ip, PORT)
	#if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		#OS.alert("Failed to start multiplayer client.")
		#return
	#multiplayer.multiplayer_peer = peer
	#print("Waiting for connected to server signal")
	#await multiplayer.connected_to_server
	#print("Connected to server")
	#start_game()
#
#func _hook_up_connection_signals() -> void:
	## We only need to spawn players on the server.
	#if not multiplayer.is_server():
		#return
	#multiplayer.peer_connected.connect(_on_player_connected_to_host)
	#multiplayer.peer_disconnected.connect(_on_player_disconnected_from_host)
#
#func _on_player_connected_to_host(id : int) -> void:
	#player_connected.emit(id)
#
#func _on_player_disconnected_from_host(id : int) -> void:
	#player_disconnected.emit(id)
#
#func start_game():
	## Hide the UI and unpause to start the game.
	##get_tree().paused = false
	#game_start.emit()
	## Only change level on the server.
	## Clients will instantiate the level via the spawner.
	#if multiplayer.is_server():
		#World.change_level.call_deferred(load(World.starting_level_path))
#
#func track_player(player : Player) -> void:
	#player_id_to_node[player.player] = player
	#print("Started tracking player ", player.player)
#
#func stop_tracking_player(player : Player) -> void:
	#player_id_to_node.erase(player.player)
	#print("Stopped tracking player ", player.player)
