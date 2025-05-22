extends Area3D
class_name interactable_area

signal interact_occured(body : Node)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body : Node) -> void:
	if body.has_signal("interact_attempted"):
		body.interact_attempted.connect(_on_overlapping_body_interact)

func _on_body_exited(body : Node) -> void:
	if body.has_signal("interact_attempted"):
		body.interact_attempted.disconnect(_on_overlapping_body_interact)

func _on_overlapping_body_interact(body : Node) -> void:
	interact_occured.emit(body)
