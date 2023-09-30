extends CharacterBody3D


const SPEED = 6.9
const FAKE_EXTRA_GRAVITY = 5
const PLOT_TYPES = ['farm', 'drill', 'oxygen pump', 'generator']
const RESOURCE_TYPES = ['food', 'oxygen']

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var carry_plot_scene = preload("res://objs/carry_plot.tscn")

@onready var animation_player: AnimationPlayer = $rotated/mesh.get_node('AnimationPlayer') as AnimationPlayer
var plot = null
var resource = null


func _ready():
  animation_player.play("idle")


func _physics_process(delta):
  movement(delta)


func _unhandled_input(event):
  unhandled_input_actions(event)


func movement(delta):
  # add the gravity
  if not is_on_floor():
    velocity.y -= gravity * delta * FAKE_EXTRA_GRAVITY

  # wasd movement
  var input_dir = Input.get_vector("left", "right", "up", "down")
  var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

  if direction:
    velocity.x = direction.x * SPEED
    velocity.z = direction.z * SPEED
  else:
    velocity.x = move_toward(velocity.x, 0, SPEED)
    velocity.z = move_toward(velocity.z, 0, SPEED)

  # animate walking
  var animation = "idle"

  if abs(velocity.x) > 0 or abs(velocity.z) > 0:
    animation = "run"

  animation_player.play(animation + "_holding" if plot or resource else animation)

  rotate_player_mesh(direction)
  move_and_slide()


func rotate_player_mesh(direction):
  var angle = 0

  if direction.x < 0 and direction.z == 0:
    angle = -90
  elif direction.x > 0 and direction.z == 0:
    angle = 90
  elif direction.z < 0 and direction.x == 0:
    angle = 180
  elif direction.z > 0 and direction.x == 0:
    angle = 0
  elif direction.x < 0 and direction.z < 0:
    angle = -135
  elif direction.x < 0 and direction.z > 0:
    angle = -45
  elif direction.x > 0 and direction.z < 0:
    angle = 135
  elif direction.x > 0 and direction.z > 0:
    angle = 45

  if direction != Vector3.ZERO:
    $rotated.rotation.y = deg_to_rad(angle)


func unhandled_input_actions(event : InputEvent):
  if event.is_action_pressed("action"):
    Action.perform()

  if event.is_action_pressed("test_plot"):
    if plot:
      switch_carry_plot()
    elif not resource:
      add_carry_plot(PLOT_TYPES.pick_random())

  if event.is_action_pressed("test_resource"):
    if resource:
      switch_resource()
    elif not plot:
      add_resource(RESOURCE_TYPES.pick_random())


func update_carry_plot_material(carry_plot):
  var material = preload("res://assets/materials/default_plot.tres")

  if plot == "farm":
    material = preload("res://assets/materials/farm.tres")
  elif plot == "drill":
    material = preload("res://assets/materials/drill.tres")
  elif plot == "oxygen pump":
    material = preload("res://assets/materials/oxygen_pump.tres")
  elif plot == "generator":
    material = preload("res://assets/materials/generator.tres")

  carry_plot.get_node('mesh').material_override = material


func add_carry_plot(type):
  var carry_plot = carry_plot_scene.instantiate()
  plot = type
  update_carry_plot_material(carry_plot)
  $rotated/carry_plot_spawn.add_child(carry_plot)
  Action.update_changes()


func remove_carry_plot():
  plot = null
  Global.remove_nodes($rotated/carry_plot_spawn)
  Action.update_changes()


func switch_carry_plot():
  var next_plot = next_thing(plot, PLOT_TYPES)
  remove_carry_plot()
  add_carry_plot(next_plot)
  Action.update_changes()


func next_thing(thing: String, array: Array):
  var index = array.find(thing)
  var next_index = index + 1

  if next_index > array.size() - 1:
    next_index = 0

  return array[next_index]

func add_resource(type):
  resource = type

  var node = null

  if resource == "food":
    node = preload("res://objs/resources/food.tscn")
  elif resource == "oxygen":
    node = preload("res://objs/resources/oxygen.tscn")

  if node:
    $rotated/carry_resource_spawn.add_child(node.instantiate())

  Action.update_changes()


func remove_resource():
  resource = null
  Global.remove_nodes($rotated/carry_resource_spawn)
  Action.update_changes()


func switch_resource():
  var next_resource = next_thing(resource, RESOURCE_TYPES)
  remove_resource()
  add_resource(next_resource)
  Action.update_changes()
