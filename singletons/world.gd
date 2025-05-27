extends Node

@export var level : Node
@export_file var starting_level_path = "res://scenes/levels/default.tscn"


# Call this function deferred and only on the main authority (server).
func change_level(scene: PackedScene):
	if not multiplayer.is_server():
		return
	# Remove old level if any.
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	# Add new level.
	level.add_child(scene.instantiate())

# The server can restart the level by pressing HOME.
func _input(event):
	if not multiplayer.is_server():
		return
	if event.is_action("ui_home") and Input.is_action_just_pressed("ui_home"):
		change_level.call_deferred(load("res://level.tscn"))


func get_player(player_id : int) -> Player:
	return level.get_child(0).get_node("Players").get_node(str(player_id))
