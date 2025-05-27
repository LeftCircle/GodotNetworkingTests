extends CharacterBody3D
class_name Player

#const Car = preload("res://scenes/characters/car.gd") # Forward declaration

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

# Reference to the car the player is currently in, if any.
var current_car : Car = null
var current_seat_node_path : NodePath = NodePath() # Path to the seat node the player is in, relative to the car

# Player synchronized input.
@onready var input = $InputSynch

func set_player_id(new_id : int) -> void:
	player = new_id
	# Give authority over input to the appropriate peer
	$InputSynch.set_multiplayer_authority(new_id)
	# Keep the authority of position and simulation state to the server.

func _ready() -> void:
	set_camera()
	#name = str(multiplayer.get_unique_id())

func set_camera() -> void:
	if player == multiplayer.get_unique_id():
		$Camera3D.current = true

func _physics_process(delta):
	if multiplayer.get_unique_id() != 1:
		prints("Inputs control self =", inputs_control_self)
	_handle_interaction()
	if inputs_control_self:
		_move_player(delta)
	elif current_car and not current_seat_node_path.is_empty():
		_update_position_in_car()

@rpc("call_local", "reliable")
func toggle_inputs_for_self(val : bool) -> void:
	inputs_control_self = val

func _update_position_in_car():
	if is_instance_valid(current_car):
		var seat_node = current_car.get_node_or_null(current_seat_node_path)
		global_transform = seat_node.global_transform
	else:
		# Car became invalid. Server should handle ejecting the player.
		# For now, we assume the server will call client_exit_vehicle if needed.
		pass

func _move_player(delta : float) -> void:
	_handle_jumping(delta)
	_handle_movement(delta) # Pass delta here
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

func _handle_movement(_delta : float) -> void:
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
		# TODO -> This logic should probably be moved to the car node.
		if current_car: # Player is in a car
			# Client requests to exit the car. Server will validate and process.
			current_car.rpc_id(1, "server_try_exit_car", player) # Use rpc_id to ensure the server processes this request
			# if is_multiplayer_authority():
			# 	current_car.rpc_id(1, "server_try_exit_car", name)
			# elif multiplayer.is_server():
			# 	current_car.server_try_exit_car(name)
		else: # Player is not in a car
			interact_attempted.emit(self)
		input.interact = false

@rpc("any_peer", "reliable", "call_local")
func client_enter_vehicle_seat(car_seat_global_transform: Transform3D, car_node_path: NodePath, seat_node_path_in_car: NodePath):
	# Ensure this client is the intended recipient (optional, as server uses rpc_id)
	# if not get_multiplayer_authority() == multiplayer.get_unique_id():
	# print("Player '%s' ignoring client_enter_vehicle_seat as it's not my authority." % name)
	# return

	prints("Player '%s' received client_enter_vehicle_seat for car '%s', seat '%s'" % [name, car_node_path, seat_node_path_in_car])
	var car_node = get_node_or_null(car_node_path)
	if car_node is Car:
		current_car = car_node
		current_seat_node_path = seat_node_path_in_car
		toggle_inputs_for_self.rpc(false)
		global_transform = car_seat_global_transform

		# CharacterBody3D physics is effectively paused by not calling move_and_slide
		# and not updating velocity when inputs_control_self is false.
	else:
		printerr("Player '%s': Car node not found at path '%s' during client_enter_vehicle_seat" % [name, car_node_path])

@rpc("any_peer", "reliable", "call_local")
func client_exit_vehicle(exit_position: Vector3):
	# Ensure this client is the intended recipient (optional, as server uses rpc_id)
	# if not get_multiplayer_authority() == multiplayer.get_unique_id():
	# print("Player '%s' ignoring client_exit_vehicle as it's not my authority." % name)
	# return

	prints("Player '%s' received client_exit_vehicle to position %s" % [name, exit_position])
	current_car = null
	current_seat_node_path = NodePath() # Reset to empty NodePath
	toggle_inputs_for_self.rpc(true)
	global_position = exit_position
