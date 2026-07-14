@tool
class_name Boca
extends Node2D

@export var states: Dictionary[float, Node2D]
var state_keys_reversed: Array[float]

func _ready() -> void:
	state_keys_reversed = states.keys()
	state_keys_reversed.sort()
	state_keys_reversed.reverse()

# Returns the lower and upper energy limit for this mouth shape
func update_energy(mouth_change_energy: float) -> Array[float]:
	for key in states:
		states[key].hide()
	var i := 0
	for limit in state_keys_reversed:
		if mouth_change_energy >= limit:
			states[limit].show()
			if i == 0:
				return [limit, 1.0]
			else:
				return [limit, state_keys_reversed[i - 1]]
		i += 1
	return [0.0, 1.0]
