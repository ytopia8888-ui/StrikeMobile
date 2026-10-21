
extends Control

signal vector_changed(value: Vector2)

var stick_value := Vector2.ZERO
var active_touch := -1
var radius := 65.0

func _ready() -> void:
    custom_minimum_size = Vector2(150, 150)
    mouse_filter = Control.MOUSE_FILTER_STOP
    queue_redraw()

func _draw() -> void:
    var center := size / 2.0
    draw_circle(center, radius, Color(0.1, 0.1, 0.1, 0.45))
    draw_arc(center, radius, 0.0, TAU, 48, Color(0.8, 0.8, 0.8, 0.7), 3.0)

    var knob_pos := center + stick_value * radius
    draw_circle(knob_pos, 27.0, Color(0.75, 0.78, 0.82, 0.85))

func _gui_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed and active_touch == -1:
            active_touch = event.index
            _update_stick(event.position)
        elif not event.pressed and event.index == active_touch:
            active_touch = -1
            _reset_stick()

    elif event is InputEventScreenDrag and event.index == active_touch:
        _update_stick(event.position)

    elif event is InputEventMouseButton:
        if event.pressed:
            active_touch = 0
            _update_stick(event.position)
        else:
            active_touch = -1
            _reset_stick()

    elif event is InputEventMouseMotion and active_touch == 0:
        _update_stick(event.position)

func _update_stick(pos: Vector2) -> void:
    var center := size / 2.0
    stick_value = ((pos - center) / radius).limit_length(1.0)
    vector_changed.emit(stick_value)
    queue_redraw()

func _reset_stick() -> void:
    stick_value = Vector2.ZERO
    vector_changed.emit(stick_value)
    queue_redraw()
