
extends CharacterBody3D

const SPEED := 2.0
const GRAVITY := 15.0

var health := 100
var target: Node3D
var main: Node
var attack_timer := 0.0
var mesh_instance: MeshInstance3D

func _ready() -> void:
    var collision := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.4
    capsule.height = 1.8
    collision.shape = capsule
    add_child(collision)

    mesh_instance = MeshInstance3D.new()
    var mesh := CapsuleMesh.new()
    mesh.radius = 0.4
    mesh.height = 1.8
    mesh_instance.mesh = mesh

    var material := StandardMaterial3D.new()
    material.albedo_color = Color(0.65, 0.18, 0.12)
    mesh_instance.material_override = material
    add_child(mesh_instance)

func _physics_process(delta: float) -> void:
    if not is_instance_valid(target):
        return

    attack_timer = maxf(0.0, attack_timer - delta)

    var offset := target.global_position - global_position
    var distance := offset.length()

    if distance > 2.5:
        var direction := offset.normalized()
        velocity.x = direction.x * SPEED
        velocity.z = direction.z * SPEED
        look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z))
    else:
        velocity.x = 0.0
        velocity.z = 0.0
        if attack_timer <= 0.0:
            attack_timer = 1.2
            if target.has_method("take_damage"):
                target.take_damage(5)

    if not is_on_floor():
        velocity.y -= GRAVITY * delta
    else:
        velocity.y = 0.0

    move_and_slide()

func take_damage(amount: int) -> void:
    health -= amount
    if health <= 0:
        if is_instance_valid(main) and main.has_method("bot_killed"):
            main.bot_killed(self)
        else:
            queue_free()
