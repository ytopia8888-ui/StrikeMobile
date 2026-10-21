
extends CanvasLayer

signal fire_pressed
signal jump_pressed
signal reload_pressed

var player
var score := 0
var health_label: Label
var ammo_label: Label
var score_label: Label

func _ready() -> void:
    var root := Control.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.mouse_filter = Control.MOUSE_FILTER_PASS
    add_child(root)

    health_label = _make_label(root, "HP: 100", Vector2(20, 20), 24)
    ammo_label = _make_label(root, "30 / 90", Vector2(20, 52), 22)
    score_label = _make_label(root, "Bots: 0", Vector2(20, 84), 20)

    var joystick = preload("res://scripts/joystick.gd").new()
    joystick.position = Vector2(35, -190)
    joystick.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
    joystick.size = Vector2(150, 150)
    root.add_child(joystick)
    joystick.vector_changed.connect(_on_joystick_changed)

    _make_button(root, "FIRE", Vector2(-150, -175), Vector2(110, 65), _fire, Control.PRESET_BOTTOM_RIGHT)
    _make_button(root, "JUMP", Vector2(-270, -110), Vector2(95, 55), _jump, Control.PRESET_BOTTOM_RIGHT)
    _make_button(root, "RELOAD", Vector2(-150, -95), Vector2(110, 50), _reload, Control.PRESET_BOTTOM_RIGHT)

func _make_label(parent: Control, text_value: String, pos: Vector2, font_size: int) -> Label:
    var label := Label.new()
    label.text = text_value
    label.position = pos
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", Color.WHITE)
    parent.add_child(label)
    return label

func _make_button(parent: Control, text_value: String, pos: Vector2, button_size: Vector2, callback: Callable, preset: Control.LayoutPreset) -> void:
    var button := Button.new()
    button.text = text_value
    button.size = button_size
    button.set_anchors_preset(preset)
    button.position = pos
    button.add_theme_font_size_override("font_size", 18)
    button.pressed.connect(callback)
    parent.add_child(button)

func _fire() -> void:
    fire_pressed.emit()

func _jump() -> void:
    jump_pressed.emit()

func _reload() -> void:
    reload_pressed.emit()

func _on_joystick_changed(value: Vector2) -> void:
    if is_instance_valid(player):
        player.set_move_input(value)

func set_player(value) -> void:
    player = value
    if is_instance_valid(player):
        player.hud = self

func set_health(value: int) -> void:
    if is_instance_valid(health_label):
        health_label.text = "HP: %d" % value

func set_ammo(current: int, reserve: int) -> void:
    if is_instance_valid(ammo_label):
        ammo_label.text = "%d / %d" % [current, reserve]

func set_score(value: int) -> void:
    score = value
    if is_instance_valid(score_label):
        score_label.text = "Bots: %d" % score
