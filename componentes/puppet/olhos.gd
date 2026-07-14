@tool
extends Node2D

@onready var olhos := [$Olho1, $Olho2] as Array[Node2D]
var blink_timer := Timer.new()
const BLINK_TEXTURE = preload("res://componentes/puppet/olho_pisca.png")


func _ready() -> void:
	olhos[0].scale = Vector2(1.0, 1.0)
	olhos[1].scale = Vector2(1.0, 1.0)
	if Engine.is_editor_hint():
		return
	blink_timer.one_shot = true
	add_child(blink_timer)
	blink_timer.timeout.connect(func():
		for olho in olhos:
			if not olho.pode_piscar:
				continue
			var tween = get_tree().create_tween()
			tween.tween_property(olho.sprite, "scale", Vector2(1.4, 0.2), 0.02).set_ease(Tween.EASE_IN)
			tween.tween_property(olho.sprite, "scale", Vector2(1.0, 1.0), 0.2).set_ease(Tween.EASE_OUT)
		blink_timer.start(randf_range(2.0, 5.0))
	)
	blink_timer.start(randf_range(2.0, 5.0))
