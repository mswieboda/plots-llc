extends CharacterBody3D


const SPEED = 6.9
const FAKE_EXTRA_GRAVITY = 5
const MODULE_TYPES = ['farm', 'drill', 'oxygen pump', 'generator']

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var carry_module_scene = preload("res://objs/carry_module.tscn")

var module = null

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

  move_and_slide()


func unhandled_input_actions(event : InputEvent):
  if event.is_action_pressed("action"):
	Action.perform()

  if event.is_action_pressed("test_module"):
	if module:
	  switch_carry_module()
	else:
	  add_carry_module(MODULE_TYPES.pick_random())


func update_carry_module_material(carry_module):
  var material = preload("res://assets/materials/default_module.tres")

  if module == "farm":
	material = preload("res://assets/materials/farm.tres")
  elif module == "drill":
	material = preload("res://assets/materials/drill.tres")
  elif module == "oxygen pump":
	material = preload("res://assets/materials/oxygen_pump.tres")
  elif module == "generator":
	material = preload("res://assets/materials/generator.tres")

  carry_module.get_node('mesh').material_override = material


func add_carry_module(type):
  var carry_module = carry_module_scene.instantiate()
  module = type
  update_carry_module_material(carry_module)
  $carry_module_spawn.add_child(carry_module)
  Action.update_changes()


func remove_carry_module():
  for node in $carry_module_spawn.get_children():
	$carry_module_spawn.remove_child(node)
	node.queue_free()

  module = null
  Action.update_changes()


func switch_carry_module():
  var module_index = MODULE_TYPES.find(module)
  var next_module_index = module_index + 1

  if next_module_index > MODULE_TYPES.size() - 1:
	next_module_index = 0

  module = MODULE_TYPES[next_module_index]

  var carry_module = $carry_module_spawn.get_child(0)
  update_carry_module_material(carry_module)
  Action.update_changes()
