@tool
extends Node2D

@onready var boca := $Boca as Node2D
@onready var anim_feliz := $Boca/Feliz as Boca
@onready var anim_triste := $Boca/Triste as Boca
@onready var spectrum := AudioServer.get_bus_effect_instance(1, 0) as AudioEffectSpectrumAnalyzerInstance
@export var is_triste := false:
	set(value):
		is_triste = value
		anim_triste.visible = is_triste
		anim_feliz.visible = not is_triste

@export var min_db = -60.0
const MOUTH_CHANGE_SPEED = 0.5
const SCALE_SPEED = 0.3

var prev_energy := 0.0
var prev_mouth_change_energy := 0.0
var prev_scale_energy := 0.0

var max_energy := 1.0

signal comecou_a_falar()
signal terminou_de_falar()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var magnitude := spectrum.get_magnitude_for_frequency_range(300, 3000).length()
	var curr_energy := clampf((absf(min_db) + linear_to_db(magnitude)) / absf(min_db), 0, 1)
	if prev_energy == 0.0 and curr_energy > 0.0:
		comecou_a_falar.emit()
	if prev_energy > 0.0 and curr_energy == 0.0:
		terminou_de_falar.emit()
	prev_energy = curr_energy
	if curr_energy > max_energy:
		max_energy = curr_energy
	var normalized_energy := remap(curr_energy, 0.0, 1.0, 0.0, max_energy)
	
	var mouth_change_energy := lerpf(prev_mouth_change_energy, normalized_energy, MOUTH_CHANGE_SPEED)
	prev_mouth_change_energy = mouth_change_energy
	
	var limits := anim_feliz.update_energy(mouth_change_energy)
	anim_triste.update_energy(mouth_change_energy)
	var new_scale_energy := remap(normalized_energy, limits[0], limits[1], -0.2, 1.0)
	var scale_energy := lerpf(prev_scale_energy, new_scale_energy, SCALE_SPEED)
	prev_scale_energy = scale_energy
	
	boca.scale = Vector2(1 - scale_energy * 0.3, 1 + scale_energy * 0.5)
