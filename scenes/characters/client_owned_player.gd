extends Player
class_name ClientOwnedPlayer


func set_player_id(new_id : int) -> void:
	super.set_player_id(new_id)
	set_multiplayer_authority(new_id, true)
