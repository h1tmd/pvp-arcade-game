extends CharacterBody2D

@export var speed = 100
@export var acceleration = 10

func _physics_process(_delta):
	var direction = Input.get_vector("left", "right", "up", "down")
	
	velocity.x = move_toward(velocity.x, speed * direction.x, acceleration)
	velocity.y = move_toward(velocity.y, speed * direction.y, acceleration)
	
	move_and_slide()
