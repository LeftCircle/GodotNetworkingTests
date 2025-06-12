extends Control
class_name Main

@export var enet_login : PackedScene
@export var steam_login : PackedScene

func _ready() -> void:
	if NetworkManager.active_network_type == NetworkManager.MULTIPLAYER_NETWORK_TYPE.STEAM:
		add_child(steam_login.instantiate())
	else:
		add_child(enet_login.instantiate())
