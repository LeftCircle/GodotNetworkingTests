extends Button
class_name DebugButton

func _ready() -> void:
	pressed.connect(_on_pressed)
	button_down.connect(_on_button_down)
	disabled = false

func _input(event: InputEvent) -> void:
	if event.is_action(&"enter"):
		pressed.emit()

func _on_pressed() -> void:
	print("Debug button ", name, " pressed")

func _on_button_down() -> void:
	print("Debug button ", name, " down")
