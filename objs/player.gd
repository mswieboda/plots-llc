extends CharacterBody3D

@export
var DEBUG = true
const SPEED = 6.9
const FAKE_EXTRA_GRAVITY = 5
const FOOD_INCREASE = 7

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var animation_player: AnimationPlayer = $rotated/mesh.get_node('AnimationPlayer') as AnimationPlayer
var plot = null
var resource = null
var raw_material = null
var dead = false

func _ready():
  animation_player.play("idle")
  add_carry_plot("drill")


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

  animation_player.play(animation + "_holding" if plot or resource or raw_material else animation)

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
  if event.is_action_pressed("menu"):
    if $esc_menu.visible:
      get_tree().paused = false
      $esc_menu.hide()
    else:
      get_tree().paused = true
      $esc_menu.show()
    return

  if $esc_menu.visible:
    if event.is_action_pressed("menu_quit"):
      get_tree().paused = false
      get_tree().quit()
    elif event.is_action_pressed("menu_restart"):
      get_tree().paused = false
      get_tree().change_scene_to_file("res://scenes/splash.tscn")
    return

  if event.is_action_pressed("action"):
    Action.perform()

  if DEBUG and event.is_action_pressed("test_plot"):
    if plot:
      switch_carry_plot()
    elif not resource and not raw_material:
      add_carry_plot(Global.PLOTS[0])

  if DEBUG and event.is_action_pressed("test_resource"):
    if resource:
      switch_resource()
    elif not plot and not raw_material:
      add_resource(Global.RESOURCES[0])

  if DEBUG and event.is_action_pressed("test_raw_material"):
    if raw_material:
      switch_raw_material()
    elif not plot and not resource:
      add_raw_material(Global.RAW_MATERIALS[0])


func add_carry_plot(type):
  plot = type
  $rotated/carry_plot_spawn.add_child(Global.create_carry_plot_node(plot))
  Action.update_changes()


func remove_carry_plot():
  plot = null
  Global.remove_nodes($rotated/carry_plot_spawn)
  Action.update_changes()


func switch_carry_plot():
  var next_plot = next_thing(plot, Global.PLOTS)

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

  $rotated/carry_resource_spawn.add_child(Global.create_resource_node(resource))

  if resource == "food":
    Action.add_action_least_priority(self)

  Action.update_changes()


func add_raw_material(type):
  raw_material = type

  $rotated/carry_raw_material_spawn.add_child(Global.create_raw_material_node(raw_material))

  Action.update_changes()


func remove_resource():
  resource = null
  Global.remove_nodes($rotated/carry_resource_spawn)
  Action.update_changes()


func remove_raw_material():
  raw_material = null
  Global.remove_nodes($rotated/carry_raw_material_spawn)
  Action.update_changes()


func switch_resource():
  var next_resource = next_thing(resource, Global.RESOURCES)

  remove_resource()

  if next_resource:
    add_resource(next_resource)

  Action.update_changes()


func switch_raw_material():
  var next_raw_material = next_thing(raw_material, Global.RAW_MATERIALS)

  remove_raw_material()

  if next_raw_material:
    add_raw_material(next_raw_material)

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
  get_node('/root/main/levels_gui').add_food(FOOD_INCREASE)
  Action.remove_action(self)
  Action.update_changes()


func die():
  dead = true
  $rotated/mesh/AnimationPlayer.play("death")


func update_changes():
  pass
