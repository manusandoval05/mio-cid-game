extends Control


export var speaker_frames = {
	"Rodrigo Díaz de Vivar": "rodrigo",
	"Martín Antolínez": "martin"
}

# Called when the node enters the scene tree for the first time.
func _ready(): 
	visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Player_dialog():
	visible = true
	$DialogueBox.start()


func _on_DialogueBox_speaker_changed(speaker):
	$SpeakerImage.animation = speaker_frames[speaker]



func _on_DialogueBox_dialogue_ended():
	visible = false 
