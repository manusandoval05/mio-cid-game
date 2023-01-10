extends KinematicBody2D

signal dialog
signal health_updated(current_health)
signal health_depleted

export var health = 100
var current_health = health
var being_hit

export var walking_speed = 200
export var attacking_walking_speed = 50
export var running_speed = 600
export var jumping_strength = 500
export var rolling_speed = 750

export var GRAVITY = 15

var current_falling_speed = 0.0
var current_jumping_strength = jumping_strength

var is_sprinting
var on_ground
var is_jumping 
var is_falling
var is_attacking

var is_rolling
var can_roll = true
var rolling_direction

var is_attacking_1
export(int) var attack_1_damage = 15
var attack_1_queue
var attack_1_damage_frames = [5]

var is_attacking_2
var attack_2_queue
export(int) var attack_2_damage = 25
var attack_2_damage_frames = [2, 5]
var is_blocking
var is_attacking_3

var already_damaged

var can_loop_animate

var in_dialog

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.ZERO
	var horizontal_speed
		
	if in_dialog: 
		velocity = Vector2.ZERO
	elif not is_rolling: 
		velocity.x = Input.get_axis("ui_left", "ui_right")
	else:
		velocity.x = rolling_direction
		
	
	if not in_dialog and not being_hit: 
		is_attacking_1 = Input.is_action_just_pressed("attack_1")
		is_attacking_2 = Input.is_action_just_pressed("attack_2") and not (is_attacking_1 or is_blocking)
		is_blocking = Input.is_action_pressed("block") and not (is_attacking_1 or is_attacking_2)
		is_attacking = is_attacking_1 or is_attacking_2 or is_blocking
		
		is_sprinting = Input.is_action_pressed("sprint") and not is_falling and can_loop_animate
	
	
	if is_rolling: 
		horizontal_speed = rolling_speed
	elif ($AnimatedSprite.animation in ["attack_1", "attack_2"]) or is_blocking:
		horizontal_speed = attacking_walking_speed
	elif is_sprinting: 
		horizontal_speed = running_speed
	else:
		horizontal_speed = walking_speed
		
	if Input.is_action_just_pressed("ui_accept") and not is_jumping and not is_falling and can_loop_animate and not in_dialog:
		jump()
	elif Input.is_action_just_pressed("roll") and not is_jumping and not is_falling and not is_rolling and velocity.x != 0 and can_roll and not in_dialog:
		rolling_direction = velocity.x
		roll()
	
	if is_jumping: 
		velocity.y -= 1
		velocity.y *= current_jumping_strength
		current_jumping_strength -= 400 * delta
	elif is_falling: 
		velocity.y += 1
		current_falling_speed += GRAVITY
		velocity.y *= current_falling_speed
		
	
	if is_attacking_2 and $AnimatedSprite.animation == "attack_2":
		attack_2_queue = true
	
	if is_attacking_1 and $AnimatedSprite.animation == "attack_1":
		attack_1_queue = true
	
	
	if velocity.y < 0 and can_loop_animate and not being_hit: 
		$AnimatedSprite.animation = "jump"
		$AnimatedSprite.flip_h = velocity.x < 0 
	elif velocity.y > 0 and can_loop_animate: 
		$AnimatedSprite.animation = "fall"
		$AnimatedSprite.flip_h = velocity.x < 0
	elif is_rolling: 
		$AnimatedSprite.animation = "roll"
		can_loop_animate = false
		$AnimatedSprite.flip_h = velocity.x < 0
	elif is_attacking_1 and not being_hit:
		$AnimatedSprite.animation = "attack_1"
		z_index = 20
		can_loop_animate = false
			
	elif is_attacking_2 and not being_hit:
		$AnimatedSprite.animation = "attack_2"
		z_index = 20
		can_loop_animate = false
		
	elif is_blocking and can_loop_animate and velocity.x != 0:
		$AnimatedSprite.animation = "block_and_walk"
	
	elif is_blocking and can_loop_animate: 
		$AnimatedSprite.animation = "block"
	elif velocity.x != 0 and is_sprinting and can_loop_animate and not being_hit: 
		$AnimatedSprite.animation = "run"
		$AnimatedSprite.flip_h = velocity.x < 0	
	elif velocity.x != 0 and can_loop_animate and not being_hit: 
		$AnimatedSprite.animation = "walk"
		$AnimatedSprite.flip_h = velocity.x < 0 
	elif velocity.length() <= 0 and can_loop_animate and not being_hit: 
		$AnimatedSprite.animation = "idle"
			
	
	if $AnimatedSprite.animation in ["attack_1", "attack_2"] and velocity.x != 0:
		$AnimatedSprite.flip_h = velocity.x < 0
	
	if $AnimatedSprite.flip_h:
		$Sword/LeftBlade.disabled = false
		$Sword/RightBlade.disabled = true
	else: 
		$Sword/LeftBlade.disabled = true
		$Sword/RightBlade.disabled = false
		
	velocity.x *= horizontal_speed
	var collision = move_and_collide(velocity * delta)
	if collision != null:
		if collision.collider.name == "Ground":
			is_falling = false
			on_ground = true
			current_falling_speed = 0
	elif not on_ground:
		fall()
	
	if $AnimatedSprite.animation == "attack_1" and $AnimatedSprite.frame in attack_1_damage_frames and not already_damaged:
		get_tree().call_group("EnemiesInHitbox", "get_attacked", attack_1_damage)
		already_damaged = true
	elif $AnimatedSprite.animation == "attack_1" and not $AnimatedSprite.frame in attack_1_damage_frames:
		 already_damaged = false
		
	if $AnimatedSprite.animation == "attack_2" and $AnimatedSprite.frame in attack_2_damage_frames and not already_damaged:
		get_tree().call_group("EnemiesInHitbox", "get_attacked", attack_2_damage)
		already_damaged = true
	# Since current frame is not a damage frame then refresh the players ability to deal damage
	# next frame with damage.
	elif $AnimatedSprite.animation == "attack_2" and not $AnimatedSprite.frame in attack_2_damage_frames:
		already_damaged = false
	

	if current_jumping_strength <= 0:
		current_jumping_strength = jumping_strength
		fall()
	
	
	if current_health <= 0: 
		emit_signal("health_depleted")

func jump(): 
	is_jumping = true 
	is_falling = false
func fall(): 
	is_jumping = false
	on_ground = false
	is_falling = true

func roll(): 
	is_rolling = true
	$RollingTimer.start()

func _on_AnimatedSprite_animation_finished():
	if not (attack_2_queue or attack_1_queue):
		can_loop_animate = true
	attack_1_queue = false
	attack_2_queue = false
	being_hit = false
	z_index = 2


func _on_RollingTimer_timeout():
	is_rolling = false
	can_roll = false
	$RollCooldownTimer.start()
	


func _on_RollCooldownTimer_timeout():
	can_roll = true


func _on_DialogueTrigger_body_entered(body):
	if body.name != "Player":
		return
	
	in_dialog = true
	emit_signal("dialog")
	
func _on_DialogueBox_dialogue_ended():
	in_dialog = false

func get_attacked(damage_received):
	if is_blocking:
		return
	
	current_health -= damage_received
	$AnimatedSprite.animation = "hit_front"
	being_hit = true
	emit_signal("health_updated", current_health)

func _on_Sword_area_entered(area):
	if "Enemies" in area.get_groups():
		area.add_to_group("EnemiesInHitbox")
	

func _on_Sword_area_exited(area):
	if "EnemiesInHitbox" in area.get_groups():
		area.remove_from_group("EnemiesInHitbox")
