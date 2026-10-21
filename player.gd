
extends CharacterBody3D

const SPEED := 5.5
const JUMP_VELOCITY := 5.0
const GRAVITY := 15.0
const MOUSE_SENSITIVITY := 0.0025

var health := 100
var ammo := 30
var reserve_ammo := 90
var fire_cooldown := 0.0
var look_delta := Vector2.ZERO
var joystick_vector := Vector2.ZERO
var jump_requested := false
var camera: Camera3D
var pitch := 0.0
var hud

func _ready() -> void:
    var collision := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.35
    capsule.height = 1.8
    collision.shape = capsule
    add_child(collision)

    camera = Camera3D.new()
    camera.position.y = 0.65
    camera.current = true
    add_child(camera)

    var gun := MeshInstance3D.new()
    var gun_mesh := BoxMesh.new()
    gun_mesh.size = Vector3(0.15, 0.15, 0.6)
    gun.mesh = gun_mesh
    gun.position = Vector3(0.28, -0.22, -0.55)
    var gun_mat := StandardMaterial3D.new()
    gun_mat.albedo_color = Color(0.12, 0.13, 0.15)
    gun.material_override = gun_mat
    camera.add_child(gun)

    add_to_group("player")

func _physics_process(delta: float) -> void:
    fire_cooldown = maxf(0.0, fire_cooldown - delta)

    if not is_on_floor():
        velocity.y -= GRAVITY * delta
    elif jump_requested:
        velocity.y = JUMP_VELOCITY

    jump_requested = false

    var move_input := joystick_vector
    if Input.is_key_pressed(KEY_W):
        move_input.y -= 1.0
    if Input.is_key_pressed(KEY_S):
        move_input.y += 1.0
    if Input.is_key_pressed(KEY_A):
        move_input.x -= 1.0
    if Input.is_key_pressed(KEY_D):
        move_input.x += 1.0

    move_input = move_input.limit_length(1.0)
    var direction := global_transform.basis * Vector3(move_input.x, 0, move_input.y)
    direction.y = 0
    direction = direction.normalized()

    velocity.x = direction.x * SPEED
    velocity.z = direction.z * SPEED
    move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
        pitch = clampf(pitch - event.relative.y * MOUSE_SENSITIVITY, -1.3, 1.3)
        camera.rotation.x = pitch

    if event is InputEventMouseButton and event.pressed:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

    if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func set_move_input(value: Vector2) -> void:
    joystick_vector = value

func look_around(delta_look: Vector2) -> void:
    rotate_y(-delta_look.x * MOUSE_SENSITIVITY)
    pitch = clampf(pitch - delta_look.y * MOUSE_SENSITIVITY, -1.3, 1.3)
    camera.rotation.x = pitch

func jump() -> void:
    if is_on_floor():
        jump_requested = true

func shoot() -> void:
    if fire_cooldown > 0.0 or ammo <= 0:
        return

    fire_cooldown = 0.18
    ammo -= 1

    var from := camera.global_position
    var to := from + (-camera.global_transform.basis.z * 80.0)
    var query := PhysicsRayQueryParameters3D.create(from, to)
    query.exclude = [get_rid()]
    var result := get_world_3d().direct_space_state.intersect_ray(query)

    if result and result.collider is Node:
        var target = result.collider
        while target and not target.has_method("take_damage"):
            target = target.get_parent()
        if target and target.has_method("take_damage"):
            target.take_damage(34)

    _update_hud()

func reload() -> void:
    if ammo >= 30 or reserve_ammo <= 0:
        return
    var needed := 30 - ammo
    var amount := mini(needed, reserve_ammo)
    ammo += amount
    reserve_ammo -= amount
    _update_hud()

func take_damage(amount: int) -> void:
    health = maxi(0, health - amount)
    _update_hud()
    if health <= 0:
        health = 100
        ammo = 30
        reserve_ammo = 90
        global_position = Vector3(0, 1, 8)
        velocity = Vector3.ZERO
        _update_hud()

func _update_hud() -> void:
    if is_instance_valid(hud):
        hud.set_health(health)
        hud.set_ammo(ammo, reserve_ammo)
