extends CanvasLayer

signal start_game  # tells the main node that the button has been pressed


func show_message(text) -> void:
    """Display message and begin timer giving message it's lifetime."""
    $MessageLabel.text = text
    $MessageLabel.show()
    $MessageTimer.start()


func show_game_over() -> void:
    """Show death message, re-display objective message, then Start button."""
    show_message("You Died.")
    yield($MessageTimer, "timeout")  # wait for show_message timer.
    $MessageLabel.text = "Dodge the\nCreeps"
    $MessageLabel.show()

    # can use this to create a temporary timer and wait for it.
    # Useful pattern for short pauses rather than a Node in the scene tree.
    yield(get_tree().create_timer(1), "timeout")
    $StartButton.show()


func update_score(score) -> void:
    """Called by main to update score displayed in HUD."""
    $ScoreLabel.text = str(score)


func _on_MessageTimer_timeout():
    $MessageLabel.hide()


func _on_StartButton_pressed():
    $StartButton.hide()
    emit_signal("start_game")

