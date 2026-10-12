extends CharacterBody2D

const SPEED:float = 15000.0

func _physics_process(delta: float) -> void:
	velocity = Input.get_vector("left","right","up","down") * delta * SPEED
	move_and_slide()
