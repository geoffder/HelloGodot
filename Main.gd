extends Node

# create `Script Variable` belonging to the Main Scene node.
# we can then drag the Mob.tscn in to in the GUI
export (PackedScene) var Mob
var SCORE: int


func _ready() -> void:
    """
    Called when the node enters the scene tree for the first time.
    """
    randomize()  # randomize seed, so random generation is always different


func new_game() -> void:
    $Music.play()
    SCORE = 0
    $HUD.update_score(SCORE)
    $HUD.show_message("Heaven or Hell\nLET'S ROCK!")
    $Player.start($StartPosition.position)
    $StartTimer.start()


func game_over() -> void:
    """
    Activated on player hit. Stop music, controller timers, and run through
    game ending messages.
    """
    $Music.stop()
    $DeathSound.play()
    $ScoreTimer.stop()
    $MobTimer.stop()
    $HUD.show_game_over()


func _on_StartTimer_timeout() -> void:
    """Begin timers responsible for coordinating gameplay."""
    $MobTimer.start()
    $ScoreTimer.start()


func _on_MobTimer_timeout() -> void:
    """
    Create a Mob instance, pick a random starting location along the Path2d,
    and set the Mob in motion.
    """
    var mob = Mob.instance()
    add_child(mob)

    $MobPath/MobSpawnLocation.set_offset(randi())
    mob.position = $MobPath/MobSpawnLocation.position

    # default mob vector is perpendicular to the spawn path, with added
    # +/- uniform variation of 45 degrees
    mob.rotation = (
        $MobPath/MobSpawnLocation.rotation
        + PI / 2
        + rand_range(-PI / 4, PI / 4)
    )

    mob.linear_velocity = Vector2(
        rand_range(mob.MIN_SPEED, mob.MAX_SPEED), 0
    ).rotated(mob.rotation)

    # tell this new node to respond to "start_game" signals from $HUD
    $HUD.connect("start_game", mob, "_on_start_game")


func _on_ScoreTimer_timeout():
    """Update scoreboard."""
    SCORE += 1
    $HUD.update_score(SCORE)
