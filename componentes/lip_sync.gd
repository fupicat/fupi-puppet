@tool
class_name LipSync
extends Node2D

@export var boca_feliz: Node2D
@export var boca_triste: Node2D
@onready var anims_feliz := boca_feliz.get_children()
@onready var anims_triste := boca_triste.get_children()
@onready var spectrum := AudioServer.get_bus_effect_instance(1, 0) as AudioEffectSpectrumAnalyzerInstance

const MIN_DB = 60
const MOUTH_CHANGE_SPEED = 0.5
const SCALE_SPEED = 0.3

var prev_energy := 0.0
var prev_mouth_change_energy := 0.0
var prev_scale_energy_feliz := 0.0
var prev_scale_energy_triste := 0.0

var max_energy := 1.0

@export var is_triste := false:
	set(value):
		is_triste = value
		boca_triste.visible = is_triste
		boca_feliz.visible = not is_triste
@export_enum("M", "A", "O", "U", "S", "Generic") var mouth_shape := "Generic"


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var magnitude := spectrum.get_magnitude_for_frequency_range(300, 3000).length()
	var curr_energy := clampf((MIN_DB + linear_to_db(magnitude)) / MIN_DB, 0, 1)
	prev_energy = curr_energy
	if curr_energy > max_energy:
		max_energy = curr_energy
	var normalized_energy := remap(curr_energy, 0.0, 1.0, 0.0, max_energy)
	
	var mouth_change_energy := lerpf(prev_mouth_change_energy, normalized_energy, MOUTH_CHANGE_SPEED)
	var mouth_shape_override := mouth_change_energy < 0.1
	prev_mouth_change_energy = mouth_change_energy
	
	var new_scale_energy_feliz := 0.0
	for shape in anims_feliz:
		shape.hide()
		if (mouth_shape_override and shape.name == "Generic") or (not mouth_shape_override and shape.name == mouth_shape):
			var limits = shape.update_energy(mouth_change_energy)
			shape.show()
			new_scale_energy_feliz = remap(normalized_energy, limits[0], limits[1], -0.2, 1.0)
	var scale_energy_feliz := lerpf(prev_scale_energy_feliz, new_scale_energy_feliz, SCALE_SPEED)
	prev_scale_energy_feliz = scale_energy_feliz
	boca_feliz.scale = Vector2(1 - scale_energy_feliz * 0.3, 1 + scale_energy_feliz * 0.5)
	
	var new_scale_energy_triste := 0.0
	for shape in anims_triste:
		shape.hide()
		if (mouth_shape_override and shape.name == "Generic") or (not mouth_shape_override and shape.name == mouth_shape):
			var limits = shape.update_energy(mouth_change_energy)
			shape.show()
			new_scale_energy_triste = remap(normalized_energy, limits[0], limits[1], -0.2, 1.0)
	var scale_energy_triste := lerpf(prev_scale_energy_triste, new_scale_energy_triste, SCALE_SPEED)
	prev_scale_energy_triste = scale_energy_triste
	boca_triste.scale = Vector2(1 - scale_energy_triste * 0.3, 1 + scale_energy_triste * 0.5)
