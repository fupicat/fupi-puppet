@tool
extends Marker2D

@export var node: Node2D


func _process(delta: float) -> void:
	if node:
		node.global_position = global_position
		node.global_rotation = global_rotation
