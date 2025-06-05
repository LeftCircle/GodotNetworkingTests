extends Control
class_name LoginScreen

func _ready() -> void:
	#Server.game_start.connect(_on_game_start)
	NetworkManager.game_start.connect(_on_game_start.bind())
	pass

func _on_host_pressed() -> void:
	print("On host pressed")
	#Server.on_host_pressed()
	NetworkManager.become_host()
	pass

func _on_client_pressed() -> void:
	var ip : String = $VBoxContainer/HBoxContainer/Remote.text
	#Server.on_connect_pressed(ip)
	NetworkManager.join_as_client()
	pass

func _on_game_start() -> void:
	queue_free()
