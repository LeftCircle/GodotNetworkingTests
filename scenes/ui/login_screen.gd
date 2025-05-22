extends Control
class_name LoginScreen

func _ready() -> void:
	Server.game_start.connect(_on_game_start)

func _on_host_pressed() -> void:
	print("On host pressed")
	Server.on_host_pressed()

func _on_client_pressed() -> void:
	var ip : String = $VBoxContainer/HBoxContainer/Remote.text
	Server.on_connect_pressed(ip)

func _on_game_start() -> void:
	queue_free()
