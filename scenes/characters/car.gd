extends CharacterBody3D
class_name Car

const CAR_SPEED = 120.0
const STEER_SPEED = 2.5
const ACCELERATION_FORCE = 150.0
const BRAKE_FORCE = 250.0
const FRICTION_FORCE = 3.0
const DRAG_COEFFICIENT = 0.4

@export var driver : Player = null
@export var passenger: Player = null

@export var seat_a_path: NodePath
@export var seat_b_path: NodePath
@export var interactable_area_path: NodePath

@export var mass: float = 150.0 # Mass of the car

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var seat_a: Node3D = get_node_or_null(seat_a_path) if seat_a_path else null
@onready var seat_b: Node3D = get_node_or_null(seat_b_path) if seat_b_path else null
@onready var _interactable_area_node: Area3D = get_node_or_null(interactable_area_path) if interactable_area_path else null

# Ensure the Car scene has a MultiplayerSynchronizer node.
# Configure it to synchronize the 'driver', 'passenger' properties, and the node's 'position' and 'rotation'.
# The Car node itself (the root of Car.tscn) should have its Multiplayer Authority set to Server (ID 1) in the editor.

func _ready() -> void:
	set_multiplayer_authority(1)
	if driver != null and not is_instance_valid(driver):
		driver = null
	if passenger != null and not is_instance_valid(passenger):
		passenger = null

	if not seat_a:
		printerr("%s: SeatA NodePath not set or node not found. Path: %s" % [name, seat_a_path])
	if not seat_b:
		printerr("%s: SeatB NodePath not set or node not found. Path: %s" % [name, seat_b_path])

	if _interactable_area_node:
		_interactable_area_node.interact_occured.connect(_on_interact_area_interact_occured)
	else:
		printerr("%s: InteractableArea NodePath not set or node not found. Path: %s" % [name, interactable_area_path])

func _physics_process(delta: float) -> void:
	var force = Vector3.ZERO
	# Velocity in the car's local coordinate system
	var local_velocity = transform.basis.inverse() * velocity

	if driver and driver.input:
		var input_vec: Vector2 = driver.input.direction
		var acceleration_input: float = -input_vec.y
		var steering_input: float = input_vec.x

		if steering_input != 0.0:
			rotate_y(steering_input * STEER_SPEED * delta)

		if acceleration_input > 0.0:
			force += -transform.basis.z * ACCELERATION_FORCE * acceleration_input
		elif acceleration_input < 0.0:
			if local_velocity.z < -0.1:
				force += transform.basis.z * BRAKE_FORCE * abs(acceleration_input)
			else:
				force += -transform.basis.z * ACCELERATION_FORCE * acceleration_input

	if velocity.length_squared() > 0.01:
		var friction = -velocity.normalized() * FRICTION_FORCE
		var drag = -velocity * velocity.length() * DRAG_COEFFICIENT
		force += friction + drag

	if not is_on_floor():
		force.y -= gravity * mass

	velocity += force / mass * delta

	set_velocity(velocity)
	move_and_slide()
	velocity = get_velocity()

func _on_interact_area_interact_occured(interacting_body: Node) -> void:
	if not interacting_body is Player:
		return

	var player_node : Player = interacting_body

	# Check if the current peer has authority over the interacting player.
	if player_node.is_multiplayer_authority():
		if multiplayer.is_server():
			# If the server itself is the authority for this player (e.g., server is hosting and playing),
			# then call the handler function directly. No RPC needed.
			_handle_player_entry_attempt(player_node)
		else:
			# If a client is the authority for this player,
			# then that client sends an RPC to the server (peer_id 1) to request car entry.
			# The car node on the server will execute server_try_enter_car.
			rpc_id(1, "server_try_enter_car", player_node.player) # Use player's integer ID
	# If player_node.is_multiplayer_authority() is false on the current peer,
	# it means this peer does not control the interacting player, so it should do nothing here.
	# The authoritative peer (client or server) will handle the interaction.

@rpc("any_peer", "reliable")
func server_try_enter_car(player_id: int):
	if not multiplayer.is_server():
		return

	var player_node = World.get_player(player_id)
	_handle_player_entry_attempt(player_node)

func _handle_player_entry_attempt(player_node: Player):
	if not is_instance_valid(player_node) or not player_node.is_inside_tree():
		printerr("Server: Invalid player node for car entry.")
		return

	if driver == null and player_node != passenger:
		_server_assign_seat(player_node.player, "driver")
	elif passenger == null and player_node != driver:
		_server_assign_seat(player_node.player, "passenger")

func _server_assign_seat(player_id: int, seat_type: String):
	if not multiplayer.is_server():
		return
	#print("Players = ", Server.player_id_to_node)
	var player_node = World.get_player(player_id)
	var seat_node_target : Node3D = null

	if seat_type == "driver":
		if seat_a:
			driver = player_node
			seat_node_target = seat_a
		else:
			printerr("Assign Seat: SeatA not found for assignment.")
			return
	elif seat_type == "passenger":
		if seat_b:
			passenger = player_node
			seat_node_target = seat_b
		else:
			printerr("Assign Seat: SeatB not found for assignment.")
			return
	else:
		printerr("Assign Seat: Invalid seat type '%s'." % seat_type)
		return

	var target_global_transform = seat_node_target.global_transform

	# The player's client (or server if local) will handle moving the player character
	var player_authority_id = player_node.get_multiplayer_authority()
	print("Multiplayer authority = ", player_authority_id, " For player ", player_node.player)
	player_node.client_enter_vehicle_seat.rpc_id(player_authority_id, target_global_transform, get_path(), seat_node_target.get_path())


@rpc("any_peer", "reliable", "call_local")
func server_try_exit_car(player_id: int):
	if not multiplayer.is_server():
		return

	var player_node = World.get_player(player_id)
	_handle_player_exit_attempt(player_node)

func _handle_player_exit_attempt(player_node: Player):
	if not is_instance_valid(player_node) or not player_node.is_inside_tree():
		printerr("Server: Invalid player node for car exit.")
		return

	if driver == player_node:
		driver = null
	elif passenger == player_node:
		passenger = null
	else:
		printerr("Server: Player %s is not in the car." % player_node.player)

	player_node.client_exit_vehicle.rpc_id(player_node.get_multiplayer_authority(), global_position)
