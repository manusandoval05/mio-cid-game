extends Node

export(PackedScene) var enemy_scene
export var spawn_cooldown_range =  [2, 4]
export(NodePath) var player_path

var spawn_positions : Array

var random

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_positions = [$LeftGenerationPosition, $RightGenerationPosition]
	random = RandomNumberGenerator.new()
	print("hello")

func generate_enemy(): 
	var enemy = enemy_scene.instance()
	enemy.position = spawn_positions[randi() % 2].position
	
	get_parent().add_child(enemy)
	
func regenerate_random_wait_time(): 
	$SpawnTimer.wait_time = random.randi_range(spawn_cooldown_range[0], spawn_cooldown_range[1])

func _on_SpawnTimer_timeout():
	generate_enemy()
	regenerate_random_wait_time()
	$SpawnTimer.start()
	
