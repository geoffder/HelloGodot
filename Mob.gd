extends RigidBody2D

export var MIN_SPEED: float = 150
export var MAX_SPEED: float = 250
var MOB_TYPES = ["walk", "swim", "fly"]


func _ready() -> void:
    """
    Called when the node enters the scene tree for the first time.
    """
    $AnimatedSprite.animation = MOB_TYPES[randi() % MOB_TYPES.size()]
    $AnimatedSprite.play()


func _on_Visibility_screen_exited() -> void:
    """When mob leaves the screen, delete it."""
    queue_free()


func _on_start_game() -> void:
    """Remove old mobs when new game is started."""
    queue_free()
