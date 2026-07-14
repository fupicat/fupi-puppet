@tool
extends Node2D


@onready var anim := $Root/Anims
@onready var lipsync := $"Root/Corpo/AnchorCabeça/CabecaNormal/LipSync"
@export var is_triste := false:
	set(value):
		is_triste = value
		if lipsync:
			lipsync.is_triste = is_triste
@export var state: State = State.NEUTRO:
	set(value):
		var old_state := state
		state = value
		if old_state == state:
			return
		if anim:
			anim.play(State.find_key(state).to_lower())
enum State {
	NEUTRO,
	OLA,
	CAMERA,
	COOL,
	COOL_CAMERA,
	SHRUG,
	HIPS,
	WINK,
	THINK,
	CIMA,
	SHOW,
	ANGRY,
	AWN,
	LAUGH,
	SHOCK,
	WORRIED,
}


func _ready() -> void:
	lipsync.is_triste = is_triste
	anim.play(State.find_key(state).to_lower())
