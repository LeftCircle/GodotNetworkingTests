extends MultiplayerInterface
class_name SteamMultiplayerInterface

const LOBBY_NAME = "HolidayRoadTestLobby"
const LOBBY_MODE = "CoOP"

var multiplayer_peer = SteamMultiplayerPeer.new()
var _hosted_lobby_id = 0

func ready() -> void:
	Steam.lobby_created.connect(_on_lobby_created)

func become_host() -> void:
	print("Starting lobby!")
	multiplayer_peer.peer_connected.connect(_add_player_to_game)
	multiplayer_peer.peer_disconnected.connect(_del_player)

	Steam.lobby_joined.connect(_on_lobby_joined.bind())
	Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC)
	game_start.emit()

func join_as_client(lobby_id):
	print("Joining lobby %s" % lobby_id)
	Steam.lobby_joined.connect(_on_lobby_joined.bind())
	Steam.joinLobby(int(lobby_id))
	game_start.emit()

func _on_lobby_created(connect: int, lobby_id):
	print("On lobby created")
	if connect == 1:
		_hosted_lobby_id = lobby_id
		print("Created lobby: %s" % _hosted_lobby_id)

		Steam.setLobbyJoinable(_hosted_lobby_id, true)

		Steam.setLobbyData(_hosted_lobby_id, "name", LOBBY_NAME)
		Steam.setLobbyData(_hosted_lobby_id, "mode", LOBBY_MODE)

		_create_host()

func _create_host():
	print("Create Host")

	var error = multiplayer_peer.create_host(0)

	if error == OK:
		multiplayer.set_multiplayer_peer(multiplayer_peer)

		if not OS.has_feature("dedicated_server"):
			_add_player_to_game(1)
	else:
		print("error creating host: %s" % str(error))

func _on_lobby_joined(lobby: int, permissions: int, locked: bool, response: int):
	print("On lobby joined")

	if response == 1:
		var lobby_owner_id = Steam.getLobbyOwner(lobby)
		if lobby_owner_id != Steam.getSteamID():
			print("Connecting client to socket...")
			connect_socket(lobby_owner_id)
	else:
		# Get the failure reason
		var fail_reason: String = SteamHelpers.get_fail_reason(response)
		print(fail_reason)

func connect_socket(steam_id: int):
	var error = multiplayer_peer.create_client(steam_id, 0)
	if error == OK:
		print("Connecting peer to host...")
		multiplayer.set_multiplayer_peer(multiplayer_peer)
	else:
		print("Error creating client: %s" % str(error))

func list_lobbies():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	# NOTE: If you are using the test app id, you will need to apply a filter on your game name
	# Otherwise, it may not show up in the lobby list of your clients
	Steam.addRequestLobbyListStringFilter("name", LOBBY_NAME, Steam.LOBBY_COMPARISON_EQUAL)
	Steam.requestLobbyList()
