extends Control
class_name SteamHub

@onready var lobby_container : VBoxContainer = $Panel/Lobbies/LobbyVBox

func _ready() -> void:
	#Server.game_start.connect(_on_game_start)
	NetworkManager.game_start.connect(_on_game_start.bind())
	Steam.lobby_match_list.connect(_on_lobby_match_list)

func _on_host_pressed() -> void:
	print("On host pressed")
	NetworkManager.become_host()


func _on_list_lobbies_pressed() -> void:
	print("List lobbies pressed")
	NetworkManager.list_lobbies()

func _on_lobby_button_pressed(lobby) -> void:
	NetworkManager.join_as_client(lobby)

func _on_lobby_match_list(lobbies : Array) -> void:
	_clear_lobbies()
	for lobby in lobbies:
		var l_name : String = Steam.getLobbyData(lobby, "name")
		var l_mode : String = Steam.getLobbyData(lobby, "mode")
		#if l_name != "" and l_name.contains(NetworkManager.active_network.LOBBY_NAME):
		var l_button : Button = Button.new()
		l_button.text = l_name + "_" + l_mode
		l_button.pressed.connect(_on_lobby_button_pressed.bind(lobby))
		lobby_container.add_child(l_button)

func _clear_lobbies() -> void:
	for lobby in lobby_container.get_children():
		lobby.queue_free()


func _on_game_start() -> void:
	queue_free()
