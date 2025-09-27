extends CharacterBody2D


const SPEED = 400.0
const JUMP_VELOCITY = -700.0
@onready var sprite_2d = $Sprite2D

var GhostScene = preload("res://ghost.tscn")

var spawned_ghosts: Array = []
const MAX_GHOSTS = 3



# a position to reset to (can be your spawn point or any Vector2)
@export var respawn_position: Vector2

func _ready():
	# if not set manually, set current position as respawn
	if respawn_position == Vector2.ZERO:
		respawn_position = global_position

func _process(delta):
	if Input.is_action_just_pressed("makeGhost"):  # custom key mapping
		spawn_ghost_and_reset()
	if Input.is_action_just_pressed("clearGhosts"):
		clear_all_ghosts()

func spawn_ghost_and_reset():
	var ghost = GhostScene.instantiate()
	ghost.global_position = global_position
	get_parent().add_child(ghost)
	
	# Add this ghost to our list
	spawned_ghosts.append(ghost)

	# If too many ghosts exist, remove the oldest one
	if spawned_ghosts.size() > MAX_GHOSTS:
		var old_ghost = spawned_ghosts.pop_front()  # remove first element
		if is_instance_valid(old_ghost):
			old_ghost.queue_free()
	
	# Reset player to respawn
	global_position = respawn_position

func clear_all_ghosts():
	for ghost in spawned_ghosts:
		if is_instance_valid(ghost):
			ghost.queue_free()
	spawned_ghosts.clear()


func _physics_process(delta: float) -> void:
	if (velocity.x > 1 || velocity.x < -1):
		sprite_2d.animation = "running"
	if (velocity.x == 0):
		sprite_2d.animation = "default"
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		sprite_2d.animation = "jumping"

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, 28)


	if Input.is_action_just_pressed("makeGhost"):
		sprite_2d.global_position
	
	move_and_slide()
	
	var isLeft = velocity.x < 0
	var isRight = velocity.x > 0
	if isLeft:
		sprite_2d.flip_h = true
	elif isRight:
		sprite_2d.flip_h = false
