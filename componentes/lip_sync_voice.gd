@tool
extends AudioStreamPlayer


@export var lipsync: LipSync
@export var nome_da_imagem := "mfa_lips"
@export_multiline var transcript := ""
@export var phonemes_array: Array[Array] = []
@export_tool_button("Gerar arquivo de lipsync") var gerar = gerar_arquivo_de_lipsync

var time_passed := 0.0
var index_atual := 0
var previous_two_shapes := ["Generic", "Generic"]
const SHAPES = {
	"a e ẽ ɐ ɐ̃ ɛ": "A",
	"o õ ɔ": "O",
	"u ũ w w̃": "U",
	"b m p": "M",
	"c d dʒ f i ĩ j j̃ k l n s t tʃ v x z ɟ ɡ ɲ ɾ ʃ ʎ ʒ": "S",
}


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not playing or Engine.is_editor_hint():
		return
	while index_atual < phonemes_array.size() - 1 and phonemes_array[index_atual][0] < time_passed:
		index_atual += 1
	var fonema_atual = phonemes_array[index_atual][1]
	var new_mouth = "Generic"
	if fonema_atual == "":
		new_mouth = previous_two_shapes[1]
	else:
		for phoneme_string in SHAPES:
			if fonema_atual in phoneme_string:
				new_mouth = SHAPES[phoneme_string]
				break
	# # Evita trocar a forma da boca todo frame, espera pelo menos 2.
	# if previous_two_shapes[1] == previous_two_shapes[0]:
		# lipsync.mouth_shape = new_mouth
	lipsync.mouth_shape = new_mouth
	previous_two_shapes.pop_front()
	previous_two_shapes.append(new_mouth)
	time_passed += delta



func gerar_arquivo_de_lipsync() -> void:
	print("Isso vai levar um bom tempo, cheque os logs do Docker para ver o progresso.")
	
	if not DirAccess.dir_exists_absolute("user://mfa_input"):
		DirAccess.make_dir_absolute("user://mfa_input")
	if not DirAccess.dir_exists_absolute("user://mfa_output"):
		DirAccess.make_dir_absolute("user://mfa_output")
	
	DirAccess.copy_absolute(stream.resource_path, "user://mfa_input/audio.wav")
	var transcript_file := FileAccess.open("user://mfa_input/audio.txt", FileAccess.WRITE)
	transcript_file.store_string(transcript)
	transcript_file.close()
	
	var response := OS.execute("docker", ["run", "--rm",
			"-v", OS.get_user_data_dir().path_join("mfa_input") + ":/data/input",
			"-v", OS.get_user_data_dir().path_join("mfa_output") + ":/data/output",
			nome_da_imagem])
	
	if response == 1:
		push_error("Mfa broke :(")
		return
	
	phonemes_array = []
	var phonemes_txt := FileAccess.open("user://mfa_output/phonemes.txt", FileAccess.READ)
	for line in phonemes_txt.get_as_text().split("\n"):
		var values := line.split(" ")
		phonemes_array.append([float(values[0]), values[1]])
