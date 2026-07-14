@tool
extends Node2D


@onready var sprite := $Sprite as Sprite2D
@export_range(0.0, 1.0, 0.01) var open := 1.0:
	set(value):
		open = value
		if sprite:
			sprite.scale = Vector2(1.4, 0.2).lerp(Vector2(1.0, 1.0), open)
@export var is_right := false
var pode_piscar := true
var shake := false
@export var state: EyeState = EyeState.NORMAL:
	set(value):
		state = value
		pode_piscar = true
		shake = false
		if not sprite:
			return
		match state:
			EyeState.NORMAL:
				sprite.texture = load("res://componentes/puppet/olho_normal.png")
			EyeState.COOL:
				sprite.texture = load("res://componentes/puppet/olho_cool.png")
			EyeState.FECHADO:
				pode_piscar = false
				sprite.texture = load("res://componentes/puppet/olho_fechado_%s.png" % ("r" if is_right else "l"))
			EyeState.SORRINDO:
				pode_piscar = false
				sprite.texture = load("res://componentes/puppet/olho_sorrindo_%s.png" % ("r" if is_right else "l"))
			EyeState.CHEEKY:
				sprite.texture = load("res://componentes/puppet/olho_cheeky_%s.png" % ("r" if is_right else "l"))
			EyeState.ANGRY:
				sprite.texture = load("res://componentes/puppet/olho_angry_%s.png" % ("r" if is_right else "l"))
			EyeState.THINK:
				sprite.texture = load("res://componentes/puppet/olho_think_l.png")
			EyeState.PISCA:
				pode_piscar = false
				sprite.texture = load("res://componentes/puppet/olho_pisca.png")
			EyeState.PISCAFORTE:
				pode_piscar = false
				sprite.texture = load("res://componentes/puppet/olho_piscaforte_%s.png" % ("r" if is_right else "l"))
			EyeState.LAUGH:
				pode_piscar = false
				sprite.texture = load("res://componentes/puppet/olho_laugh_%s.png" % ("r" if is_right else "l"))
			EyeState.AWN:
				pode_piscar = false
				shake = true
				sprite.texture = load("res://componentes/puppet/olho_awn_%s.png" % ("r" if is_right else "l"))
			EyeState.SCARE:
				sprite.texture = load("res://componentes/puppet/olho_scare.png")
			EyeState.WORRIED:
				sprite.texture = load("res://componentes/puppet/olho_worried_%s.png" % ("r" if is_right else "l"))

enum EyeState {
	NORMAL,
	COOL,
	FECHADO,
	SORRINDO,
	CHEEKY,
	ANGRY,
	THINK,
	PISCA,
	PISCAFORTE,
	LAUGH,
	AWN,
	SCARE,
	WORRIED,
}

func _process(_delta: float) -> void:
	if shake:
		sprite.offset.x = sin(Time.get_ticks_msec() * 0.04) * 3
	else:
		sprite.offset.x = 2
