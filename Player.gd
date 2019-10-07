extends Area2D
# emit when Player collides with an enemy
signal hit


export var ACCELERATION = .75  # pixels/sec
export var MAX_SPEED = 600
export var DTAU = 1  # momentum decay time constant
var SCREEN_SIZE  # size of the game window
var VELOCITY


func _ready() -> void:
    SCREEN_SIZE = get_viewport().size
    VELOCITY = Vector2(0, 0)
    hide()  # hide player at game start


func _process(delta: float) -> void:
    """
    Called every frame. 'delta' is the elapsed time since the previous frame.
    Calculate velocity, animate sprite, and move the player.
    """
    VELOCITY = control_velocity(VELOCITY)

    VELOCITY = decay_velocity(VELOCITY, delta, DTAU)

    update_sprite(VELOCITY)

    move(VELOCITY, delta)


func _on_Player_body_entered(body) -> void:
    """
    Handle collision with enemys.
    """
    hide()  # hide player body on hit
    emit_signal("hit")
    # prevent multiple collision triggers
    $CollisionShape2D.set_deferred("disabled", true)


func start(pos: Vector2) -> void:
    """
    Called when starting a new round, place player in given (x, y) position,
    reveal it and enable collision detection of the node.
    """
    position = pos
    show()
    $CollisionShape2D.disabled = false


func control_velocity(velocity: Vector2) -> Vector2:
    """
    Adjust player velocity with directions given by the users input.
    """
    var change = Vector2(0, 0)

    # get user input
    if Input.is_action_pressed("ui_right"):
        change.x += 1
    if Input.is_action_pressed("ui_left"):
        change.x -= 1
    if Input.is_action_pressed("ui_down"):
        change.y += 1
    if Input.is_action_pressed("ui_up"):
        change.y -= 1

    # normalize to 1, so diagonal isn't faster (1 + 1)
    velocity += change.normalized() * ACCELERATION

    velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
    velocity.y = clamp(velocity.y, -MAX_SPEED, MAX_SPEED)

    return velocity


func decay_velocity(velocity: Vector2, delta: float, dtau: float) -> Vector2:
    """
    Decellerate player according to time passed since the previos frame
    (delta) and the decay constant (dtau), funtionally like friction.
    """
    var decay = velocity * (1 - exp(-delta/dtau))
    return velocity - decay


func update_sprite(velocity: Vector2) -> void:
    """
    Select the correct sprite, orient it in the correct direction, and
    play/stop the animation depending on whether it is moving and in what
    direction.
    """
    if velocity.x != 0 or velocity.y != 0:
        if velocity.x != 0:
            $AnimatedSprite.animation = "right"
            $AnimatedSprite.flip_v = false
            $AnimatedSprite.flip_h = velocity.x < 0
        elif velocity.y != 0:
            $AnimatedSprite.animation = "up"
            $AnimatedSprite.flip_v = velocity.y > 0

        # alias for get_node("AnimatedSprite"), accessing by relative path.
        # AnimatedSprite is a child node in this case.
        $AnimatedSprite.play()
    else:
        $AnimatedSprite.stop()


func move(velocity: Vector2, delta: float) -> void:
    """
    Update player position according to current velocity, and prevent escape
    from the play area.
    """
    # position is a global attribute of the Area2d node
    position += velocity * delta

    # ensure user can not move out of the game area
    position.x = clamp(position.x, 0, SCREEN_SIZE.x)
    position.y = clamp(position.y, 0, SCREEN_SIZE.y)

