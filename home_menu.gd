extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_play_pressed() -> void:
	print("IM PRESSED")
	get_tree().change_scene_to_file("res://outside.tscn")


func _on_quit_pressed() -> void:
	print("IM PRESSED TOO!")
	get_tree().change_scene_to_file("res://sure.tscn")


func _on_button_pressed() -> void:
	OS.shell_open("https://forms.gle/wAXSgHfiN3Fj2YjF7")
