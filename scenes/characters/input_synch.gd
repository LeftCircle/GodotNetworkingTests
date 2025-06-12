extends MultiplayerSynchronizer
class_name PlayerInputSynch

@export var jumping : bool = false
@export var interact : bool = false

# Synched properties must be export variables
@export var direction : Vector2 = Vector2.ZERO


# Only process for the local player
func _ready():
	#set_multiplayer_authority(multiplayer.get_unique_id())
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())

# Has to be set via rpc - for some reason just synching jumping doesn't work
# for clients.
# I feel like there has to be a better way.
@rpc("call_local", "reliable")
func jump():
	jumping = true

@rpc("call_local", "reliable")
func interact_pressed() -> void:
	interact = true

func _process(delta):
	direction = Input.get_vector(&"move_left", &"move_right", &"move_down", &"move_up")
	if Input.is_action_just_pressed(&"jump"):
		jump.rpc()
		#jump()
	if Input.is_action_just_pressed(&"interact"):
		interact_pressed.rpc()
		#interact_pressed()
