@tool
extends Node2D


@onready var anim := $AnimationPlayer as AnimationPlayer
@export var state: BodyState = BodyState.NORMAL:
	set(value):
		var old_state := state
		state = value
		if old_state == state:
			return
		if anim:
			anim.play(BodyState.find_key(old_state).to_lower() + "_to_" + BodyState.find_key(state).to_lower())
enum BodyState {
	NORMAL,
	PUFFED,
	CURVED,
}
