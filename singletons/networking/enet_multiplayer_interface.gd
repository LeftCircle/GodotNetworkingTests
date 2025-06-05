extends MultiplayerInterface
class_name EnetMultiplayerInterface

const SERVER_PORT = 8080
const SERVER_IP = "127.0.0.1"

var multiplayer_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()

func become_host():
	print("Starting host!")

	multiplayer_peer.create_server(SERVER_PORT)
	multiplayer.multiplayer_peer = multiplayer_peer

	multiplayer.peer_connected.connect(_add_player_to_game)
	multiplayer.peer_disconnected.connect(_del_player)

	if not OS.has_feature("dedicated_server"):
		_add_player_to_game(1)
	game_start.emit()

func join_as_client(lobby_id):
	print("Player 2 joining")

	multiplayer_peer.create_client(SERVER_IP, SERVER_PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
	game_start.emit()
