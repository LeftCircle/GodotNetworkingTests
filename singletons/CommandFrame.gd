extends Node

const MAX_PHYSICS_AHEAD = 0
const MAX_PHYSICS_BEHIND = 0
const DOUBLE_ITERATIONS_BEHIND = 5

# max frame number is 3 bytes of data
const MAX_FRAME_NUMBER = 16777215
const MAX_FRAME_FOR_MOD = MAX_FRAME_NUMBER + 1
const BUFFER_PAD = 2
#const MAX_FRAME_NUMBER = 255

var half_max_frame = MAX_FRAME_NUMBER / 2
var frame_length_sec : float = 1.0 / float(ProjectSettings.get_setting("physics/common/physics_ticks_per_second"))
var frame_length_msec : float = frame_length_sec * 1000
var frame = 0
var clients_ahead_by : int = 1
var client_buffer_pad : int = 5
var latency_buffer_pad : int = 10
var client_buffer : int = 1
var compressed_frame : Array
var debug_last_frame_start = 0
var debug_current_frame_start = 0
#var input_processing : InputProcessing
#var player_sync_controller = PlayerSyncController.new()


var previous_command_frame : int = -1
signal command_frame_process(delta, frame_number)

func execute():
	previous_command_frame = frame
	#var expected_frame = int((float(Time.get_ticks_msec()) / frame_length_msec)) % MAX_FRAME_NUMBER
	#frame = _account_for_real_time_command_frames(expected_frame)
	frame = (frame + 1) % MAX_FRAME_NUMBER
	#compressed_frame = BaseCompression.compress_frame_into_3_bytes(frame)
	assert(frame != previous_command_frame)
	assert(frame <= MAX_FRAME_NUMBER)
	Logging.log_line("------------------------ COMMAND FRAME " + str(frame) + " ------------------------")
	#debug_last_frame_start = debug_current_frame_start
	#debug_current_frame_start = Time.get_ticks_msec()
	#var td = (debug_current_frame_start - debug_last_frame_start)
	#Logging.log_line("Frame time = " + str(td))
	#get_tree().multiplayer.poll()
	#var poll_funcref = funcref(get_tree().multiplayer, "poll")
	#FunctionQueue.queue_funcref(poll_funcref, [FunctionQueue.FUNC_IS_VOID])

#func _process(delta):
#	multiplayer.poll()
#	pass

func command_frame_greater_than_previous(frame_n : int, previous_frame : int) -> bool:
	return (((frame_n > previous_frame) and (frame_n - previous_frame <= half_max_frame)) or
			(frame_n < previous_frame) and (previous_frame - frame_n > half_max_frame))

# frame_a >= frame_b
func greater_than_or_eq_to(frame_a : int, frame_b : int) -> bool:
	if frame_a == frame_b:
		return true
	return command_frame_greater_than_previous(frame_a, frame_b)

func difference_when_actual_is_ahead(expected_frame : int, actual_frame : int) -> int:
	assert(!command_frame_greater_than_previous(expected_frame, actual_frame))
	var diff = 0
	if abs(actual_frame - expected_frame) > half_max_frame:
		# Actual has wrapped around but expected has not
		diff = MAX_FRAME_NUMBER - expected_frame + actual_frame
	else:
		diff = actual_frame - expected_frame
	return diff

func frame_difference(future_frame : int, past_frame : int) -> int:
	if abs(past_frame - future_frame) > half_max_frame:
		# Frame wraparound has occured.
		if past_frame < future_frame:
			# The past frame is actually ahead!
			var frames_till_wrap = MAX_FRAME_NUMBER - future_frame
			return -(frames_till_wrap + past_frame)
		else:
			var frames_till_wrap = MAX_FRAME_NUMBER - past_frame
			return future_frame + frames_till_wrap
	else:
		return future_frame - past_frame

func frame_difference_float(future_frame : float, past_frame : float) -> float:
	if abs(past_frame - future_frame) > half_max_frame:
		# Frame wraparound has occured.
		if past_frame < future_frame:
			# The past frame is actually ahead!
			var frames_till_wrap = MAX_FRAME_NUMBER - future_frame
			return -(frames_till_wrap + past_frame)
		else:
			var frames_till_wrap = MAX_FRAME_NUMBER - past_frame
			return future_frame + frames_till_wrap
	else:
		return future_frame - past_frame

func get_frame_number_from_expected(expected_frame_n : int) -> int:
	if expected_frame_n < 0:
		assert(abs(expected_frame_n) <= MAX_FRAME_NUMBER)
		return MAX_FRAME_NUMBER + expected_frame_n
	return expected_frame_n % MAX_FRAME_NUMBER

func get_next_frame(from_frame : int = frame) -> int:
	return (from_frame + 1) % MAX_FRAME_NUMBER

func get_past_frame(frame_n : int, frames_back : int) -> int:
	return posmod(frame_n - frames_back, MAX_FRAME_FOR_MOD)

func get_previous_frame(frame_n : int, n_frames_back = 1) -> int:
	return posmod(frame_n - n_frames_back, MAX_FRAME_FOR_MOD)

func frames_between_past_and_future(past_frame, future_frame) -> Array:
	var array = []
	if past_frame == future_frame:
		return [future_frame]
	if future_frame > past_frame:
		for i in range(past_frame, future_frame + 1):
			array.append(i)
		return array
	else:
		for i in range(past_frame, MAX_FRAME_NUMBER):
			array.append(i)
		for i in range(0, future_frame):
			array.append(i)
	return array

func set_clients_ahead_by(n_frames : int) -> void:
	clients_ahead_by = n_frames

func set_client_buffer(n_frames : int) -> void:
	client_buffer = n_frames

func get_command_frame_number() -> int:
	return int((float(Time.get_ticks_msec()) / frame_length_msec))
