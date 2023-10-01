extends CharacterBody3D


const SPEED = 6.9
const FAKE_EXTRA_GRAVITY = 5
const PLOT_TYPES = ['farm', 'drill', 'oxygen pump', 'solar panel']
const RESOURCE_TYPES = ['food', 'oxygen']

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var animation_player: AnimationPlayer = $rotated/mesh.get_node('AnimationPlayer') as AnimationPlayer
var plot = null
var resource = null
var dead = false

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

  if dead:
    return

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

    if not $audio_footsteps_player.playing:
      $audio_footsteps_player.play()
  else:
    $audio_footsteps_player.stop()

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
      add_carry_plot(PLOT_TYPES[0])

  if event.is_action_pressed("test_resource"):
    if resource:
      switch_resource()
    elif not plot:
      add_resource(RESOURCE_TYPES[0])


func add_carry_plot(type):
  plot = type

  var carry_plot_scene = preload("res://objs/plots/carry_default.tscn")

  if plot == "farm":
    carry_plot_scene = preload("res://assets/models/plots/farm/plant.gltf")
  elif plot == "drill":
    carry_plot_scene = preload("res://assets/models/plots/drill/drill.gltf")
  elif plot == "solar panel":
    carry_plot_scene = preload("res://assets/models/plots/solar_panel/solar_module_joined.gltf")
  elif plot == "oxygen pump":
    carry_plot_scene = preload("res://assets/models/plots/o2/o2.gltf")

  $rotated/carry_plot_spawn.add_child(carry_plot_scene.instantiate())
  Action.update_changes()


func remove_carry_plot():
  plot = null
  Global.remove_nodes($rotated/carry_plot_spawn)
  Action.update_changes()


func switch_carry_plot():
  var next_plot = next_thing(plot, PLOT_TYPES)

  remove_carry_plot()

  if next_plot:
    add_carry_plot(next_plot)

  Action.update_changes()


func next_thing(thing: String, array: Array):
  var index = array.find(thing)
  var next_index = index + 1

  if next_index == array.size():
    return null
  elif next_index > array.size():
    next_index = 0

  return array[next_index]

func add_resource(type):
  resource = type

  var node = null

  if resource == "food":
    node = preload("res://objs/resources/food.tscn")
    Action.add_action(self)
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

  if next_resource:
    add_resource(next_resource)

  Action.update_changes()


func get_action_name():
  return "eat food"


func get_action_info():
  return ""


func can_perform():
  return resource == "food"


func perform():
  if resource != "food":
    return

  $audio_eating_player.play()

  remove_resource()
  get_node('/root/main/levels_gui').add_food(5)
  Action.remove_action(self)
  Action.update_changes()


func update_changes():
  pass
