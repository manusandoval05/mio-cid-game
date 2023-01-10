extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(bool) var active 
# Called when the node enters the scene tree for the first time.
func _ready():
	if not active: 
		$CollisionShape2D.disabled = true
		$AnimatedSprite.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
