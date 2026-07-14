@tool
extends Node2D


@onready var boing := $Puppet/Root/Boing

## Clique aqui para ver quais dispositivos de gravação você tem.
## Abra a aba de Saída para ver os resultados.
@export_tool_button("Quais são meus microfones?") var mics = func() -> void:
	print("Seus dispositivos de gravação:")
	for mic in AudioServer.get_input_device_list():
		print(mic)
## Cole aqui o nome do dispositivo que você quer usar.
@export var microfone := "Default"
## Se estiver muito sensível, ou o seu microfone tiver ruído,
## tente aumentar o valor de min_db abaixo. Por padrão, a boca abre
## com qualquer barulho acima de -60db
@export var min_db := -60.0



func _ready() -> void:
	if Engine.is_editor_hint():
		return
	AudioServer.input_device = microfone
	$"Puppet/Root/Corpo/AnchorCabeça/CabecaNormal/LipSync".min_db = min_db
	print(AudioServer.input_device)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	$Mic.playing = true
	
	get_window().size = Vector2(1280, 720)
	var screen_size = DisplayServer.screen_get_size()
	var window_size = DisplayServer.window_get_size()
	var center = (screen_size - window_size) / 2.0
	DisplayServer.window_set_position(center)
	
	for state in $Puppet.State:
		var butt := Button.new()
		butt.text = state
		butt.pressed.connect(func():
			$Puppet.state = $Puppet.State[state]
		)
		$VBoxContainer.add_child(butt)
	var triste_butt := Button.new()
	triste_butt.toggle_mode = true
	triste_butt.text = "TRISTE????"
	triste_butt.toggled.connect(func(on: bool):
		$Puppet.is_triste = on
	)
	$VBoxContainer.add_child(triste_butt)


func _on_lip_sync_comecou_a_falar() -> void:
	boing.play("up")


func _on_lip_sync_terminou_de_falar() -> void:
	boing.play("down")
