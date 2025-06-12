extends Node

# A way to print output to a text file instead of printing to console
var log_name : String
var log_file : FileAccess
var logging_enabled = true
var server_logging_enabled = false
var n_server_sends = 0
var n_server_receives = 0

func _ready():
	log_name = "user://SERVER.log"
	if is_logging_enabled():
		_create_log_file()

func is_logging_enabled() -> bool:
	return logging_enabled

func log_server_send(info : String) -> void:
	if server_logging_enabled:
		info = "send " + str(n_server_sends) + " | " + info
		n_server_sends += 1
		_store_line(info)

func log_server_receive(info : String) -> void:
	if server_logging_enabled:
		info = "receive " + str(n_server_receives) + " | " + info
		n_server_receives += 1
		_store_line(info)

func _store_line(info : String) -> void:
	if logging_enabled:
		info = str(CommandFrame.frame) + " | " + info
		log_file.store_line(info)

func log_line(info : String) -> void:
	if logging_enabled:
		info = str(CommandFrame.frame) + " | " + info
		log_file.store_line(info)

func log_object_vars(obj) -> void:
	if logging_enabled:
		var properties = obj.get_script().get_script_property_list()
		for property in properties:
			Logging.log_line(property.name + " = " + str(obj.get(property.name)))

func _create_log_file():
	log_file = FileAccess.open(log_name, FileAccess.WRITE)


func log_dict_as_json(dict : Dictionary) -> void:
	if logging_enabled:
		log_file.store_line(JSON.new().stringify(dict))

func peer_print(msg : String) -> void:
	print(str(multiplayer.get_unique_id()) + " " + msg)
