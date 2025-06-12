extends Control
class_name LoginScreen

func _ready() -> void:
	#Server.game_start.connect(_on_game_start)
	NetworkManager.game_start.connect(_on_game_start.bind())

func _on_host_pressed() -> void:
	print("On host pressed")
	NetworkManager.become_host()

func _on_client_pressed() -> void:
	var ip : String = $VBoxContainer/HBoxContainer/Remote.text
	NetworkManager.join_as_client()

func _on_game_start() -> void:
	queue_free()
