extends Node

@export var level : Node
@export_file var starting_level_path = "res://scenes/levels/default.tscn"


func _ready() -> void:
	NetworkManager.game_start.connect(_on_game_start)

# Call this function deferred and only on the main authority (server).
func change_level(scene: PackedScene):
	if not multiplayer.get_unique_id() == 1:
		return
	# Remove old level if any.
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	# Add new level.
	level.add_child(scene.instantiate())

# The server can restart the level by pressing HOME.
func _input(event):
	if not multiplayer.get_unique_id() == 1:
		return
	if event.is_action("ui_home") and Input.is_action_just_pressed("ui_home"):
		change_level.call_deferred(load("res://level.tscn"))


func get_player(player_id : int) -> CharacterBody3D:
	return level.get_child(0).get_node("Players").get_node(str(player_id))

func _on_game_start() -> void:
	if multiplayer.get_unique_id() == 1:
		change_level.call_deferred(load(World.starting_level_path))
