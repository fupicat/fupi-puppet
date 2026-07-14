@tool
extends Node2D


@onready var anim := $AnimationPlayer as AnimationPlayer
@export var state: State = State.NORMAL:
	set(value):
		var old_state := state
		state = value
		if old_state == state:
			return
		if anim:
			anim.play(State.find_key(state).to_lower())
enum State {
	NORMAL,
	HIP,
	SHRUG,
	OMG,
	AWN,
	LAUGH,
}
