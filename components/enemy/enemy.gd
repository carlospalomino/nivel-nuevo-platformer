class_name Enemy
extends CharacterBody2D

## How fast does your enemy move?
@export_range(0, 1000, 10, "suffix:px/s") var speed: float = 100.0:
	set = _set_speed

## Does the enemy fall off edges?
@export var fall_off_edge: bool = false

## Does the player lose a life when contacting the enemy?
@export var player_loses_life: bool = true

## Can the enemy be squashed by the player?
@export var squashable: bool = true

## Variable para la direccion del enemigo (left horizontal, Right vertical)
@export_enum("Left/Up:0", "Right/Down:1") var start_direction: int = 0

## Variable para el tipo de movimiento
@export_enum("Horizontal:0", "Vertical:1") var movement_type: int = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var direction: int

@onready var _sprite := %AnimatedSprite2D
@onready var _left_ray := %LeftRay
@onready var _right_ray := %RightRay


func _set_speed(new_speed):
	speed = new_speed
	if is_node_ready():
		_sprite.speed_scale = speed / 100


func _ready():
	Global.gravity_changed.connect(_on_gravity_changed)

	direction = -1 if start_direction == 0 else 1


func _physics_process(delta):
	## Aca se configuro para que se pueda hacer efectivo el movimiento
	## este es el horizontal
	if movement_type == 0:
		# Add the gravity.
		if not is_on_floor():
			velocity.y += gravity * delta

		if not fall_off_edge and (_left_ray.is_colliding() or _right_ray.is_colliding()):
			if direction == -1 and not _left_ray.is_colliding():
				direction = 1
			elif direction == 1 and not _right_ray.is_colliding():
				direction = -1

		velocity.x = direction * speed

		_sprite.flip_h = velocity.x < 0

		move_and_slide()

		if velocity.x == 0 and is_on_floor():
			direction *= -1
	else:
		## Este es el vertical ignora la gravedad
		velocity.x = 0
		velocity.y = direction * speed

		move_and_slide()
		## al chocar cambia de direccion
		if velocity.y == 0:
			direction *= -1


func _on_gravity_changed(new_gravity):
	gravity = new_gravity


func _on_hitbox_body_entered(body):
	if body.is_in_group("players"):
		if squashable and body.velocity.y > 0 and body.position.y < position.y:
			body.stomp()
			queue_free()
		elif player_loses_life:
			Global.lives -= 1
