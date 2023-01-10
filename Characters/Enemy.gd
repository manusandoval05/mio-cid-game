extends Area2D

signal died

export(NodePath) var player_path
export var SPEED = 100
export var damage = 20
export var health = 50
var current_health = health 

var player

var in_attack_range = false
var already_damaged
# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node("../Player")
	$Sword.connect("body_entered", self, "_on_Sword_body_entered")
	$Sword.connect("body_exited", self, "_on_Sword_body_exited")
	$AnimatedSprite.connect("animation_finished", self, "_on_AnimatedSprite_animation_finished")
	add_to_group("Enemies")

func _process(delta):
	var player_position = player.position
	var destination = Vector2(player_position.x, position.y)
	$AnimatedSprite.flip_h = position.x > player.position.x
	
	if not in_attack_range:
		position = position.move_toward(destination, delta * SPEED)
	
	if abs(destination.x - position.x) > 150: 
		in_attack_range = false
		$AnimatedSprite.animation = "walk"
	
	if $AnimatedSprite.animation == "attack" and $AnimatedSprite.frame == 3 and in_attack_range and not already_damaged:
		already_damaged = true
		z_index = 10
		get_tree().call_group("Player", "get_attacked", damage)
		
func get_attacked(damage_received):
	current_health -= damage_received
	$AnimatedSprite.modulate = Color.red
	if current_health <= 0:
		emit_signal("died")
		queue_free()
	
func _on_Sword_body_entered(_body):
	in_attack_range = true
	$AnimatedSprite.animation = "attack"
	

func _on_Sword_body_exited(_body):
	in_attack_range = false
	$AnimatedSprite.animation = "walk"


func _on_AnimatedSprite_animation_finished():
	z_index = 0
	$AnimatedSprite.modulate = Color.white
	already_damaged = false


