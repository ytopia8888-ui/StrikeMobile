
extends Node3D

const PlayerScript = preload("res://scripts/player.gd")
const BotScript = preload("res://scripts/bot.gd")
const HUDScript = preload("res://scripts/hud.gd")

var player
var hud
var bots: Array[Node3D] = []
var score := 0

func _ready() -> void:
    _create_world()
    _create_player()
    _create_bots()
    _create_hud()

func _create_world() -> void:
    var environment := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_SKY
    env.sky = Sky.new()
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.55, 0.6, 0.7)
    env.ambient_light_energy = 0.8
    environment.environment = env
    add_child(environment)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-55, -30, 0)
    sun.light_energy = 1.2
    add_child(sun)

    var floor_body := StaticBody3D.new()
    floor_body.name = "Floor"
    add_child(floor_body)

    var floor_mesh := MeshInstance3D.new()
    var plane := BoxMesh.new()
    plane.size = Vector3(32, 0.5, 32)
    floor_mesh.mesh = plane
    floor_mesh.position.y = -0.25
    var floor_mat := StandardMaterial3D.new()
    floor_mat.albedo_color = Color(0.25, 0.29, 0.27)
    floor_mesh.material_override = floor_mat
    floor_body.add_child(floor_mesh)

    var floor_collision := CollisionShape3D.new()
    var floor_shape := BoxShape3D.new()
    floor_shape.size = Vector3(32, 0.5, 32)
    floor_collision.shape = floor_shape
    floor_collision.position.y = -0.25
    floor_body.add_child(floor_collision)

    _make_wall(Vector3(0, 1, -16), Vector3(32, 2, 0.5))
    _make_wall(Vector3(0, 1, 16), Vector3(32, 2, 0.5))
    _make_wall(Vector3(-16, 1, 0), Vector3(0.5, 2, 32))
    _make_wall(Vector3(16, 1, 0), Vector3(0.5, 2, 32))

    for i in range(8):
        var x := float((i % 4) * 6 - 9)
        var z := float((i / 4) * 9 - 4)
        _make_wall(Vector3(x, 0.8, z), Vector3(2.0, 1.6, 2.0))

func _make_wall(pos: Vector3, dimensions: Vector3) -> void:
    var body := StaticBody3D.new()
    body.position = pos
    add_child(body)

    var mesh_instance := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = dimensions
    mesh_instance.mesh = mesh
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.38, 0.4, 0.42)
    mesh_instance.material_override = mat
    body.add_child(mesh_instance)

    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = dimensions
    collision.shape = shape
    body.add_child(collision)

func _create_player() -> void:
    player = CharacterBody3D.new()
    player.name = "Player"
    player.set_script(PlayerScript)
    player.position = Vector3(0, 1, 8)
    add_child(player)

func _create_bots() -> void:
    for i in range(5):
        var bot := CharacterBody3D.new()
        bot.name = "Bot_%d" % i
        bot.set_script(BotScript)
        bot.position = Vector3(float((i % 3) * 5 - 5), 1, float(-5 - (i / 3) * 5))
        bot.set("target", player)
        bot.set("main", self)
        add_child(bot)
        bots.append(bot)

func _create_hud() -> void:
    hud = HUDScript.new()
    hud.name = "HUD"
    add_child(hud)
    hud.fire_pressed.connect(_on_fire_pressed)
    hud.jump_pressed.connect(_on_jump_pressed)
    hud.reload_pressed.connect(_on_reload_pressed)
    hud.set_player(player)

func _on_fire_pressed() -> void:
    if is_instance_valid(player):
        player.shoot()

func _on_jump_pressed() -> void:
    if is_instance_valid(player):
        player.jump()

func _on_reload_pressed() -> void:
    if is_instance_valid(player):
        player.reload()

func bot_killed(bot: Node) -> void:
    score += 1
    if is_instance_valid(hud):
        hud.set_score(score)
    bots.erase(bot)
    if is_instance_valid(bot):
        bot.queue_free()
    if bots.is_empty():
        _create_bots()
