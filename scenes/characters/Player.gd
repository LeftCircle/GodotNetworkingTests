extends CharacterBody3D
class_name Player

signal interact_attempted(Player)

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Set by authority and synched on spawn
@export var player : int : set = set_player_id
# A synced variable that determines if the players movement is being controlled
# by their inputs. This would be false if the player is in the car or driving
# the car.
@export var inputs_control_self : bool = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Player synchronized input.
@onready var input = $InputSynch

func set_player_id(new_id : int) -> void:
	player = new_id
	# Give authority over input to the appropriate peer
	$InputSynch.set_multiplayer_authority(new_id)
	# Keep the authority of position and simulation state to the server.

func _ready() -> void:
	set_camera()

func set_camera() -> void:
	if player == multiplayer.get_unique_id():
		$Camera3D.current = true

func _physics_process(delta):
	_handle_interaction()
	if inputs_control_self:
		_move_player(delta)

func _move_player(delta : float) -> void:
	_handle_jumping(delta)
	_handle_movement(delta)
	move_and_slide()

func _handle_jumping(delta : float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if input.jumping and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Reset jump state.
	input.jumping = false

func _handle_movement(delta : float) -> void:
	# Handle movement.
	var direction = (transform.basis * Vector3(input.direction.x, 0, input.direction.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

func _handle_interaction() -> void:
	if input.interact:
		interact_attempted.emit(self)
		input.interact = false
