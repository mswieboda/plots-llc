extends "res://objs/actionable.gd"

@onready var player = get_node("/root/main/player")

var type = null
var resource = null

func _ready():
  update_mesh_type()


func get_action_name():
  if type:
    if not player.resource and player.plot and player.plot != type:
      return "replace with %s" % player.plot
    elif resource:
      return "grab %s" % resource if not player.resource and not player.plot else ""
    else:
      return "remove %s" % type if not player.plot else ""

  return "plot %s" % player.plot if player.plot else ""


func can_perform():
  if player.resource:
    return false

  if player.plot:
    return player.plot != type

  return !!type


func perform():
  if resource:
    grab_resource()
  elif player.plot:
    remove_plot()
    type = player.plot
    play_plot_added()
    player.remove_carry_plot()
    update_mesh_type()
  elif type:
    player.add_carry_plot(type)
    remove_plot()
    update_mesh_type()


func remove_plot():
  $oxygen_spawn_timer.stop()
  $plant_grow_timer.stop()
  $metal_spawn_timer.stop()
  $plot_audio.stop()
  resource = null
  type = null


func update_changes():
  update_actionable_material()


func update_actionable_material():
  if Action.is_action_node(self) and can_perform():
    var material = StandardMaterial3D.new()
    material.albedo_color = Color(1, 1, 1, 0.069)
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

    var mesh = $mesh_spawn/mesh.find_child("Cube")

    if mesh:
      mesh.set_surface_override_material(0, material)
  else:
    var mesh = $mesh_spawn/mesh.find_child("Cube")

    if mesh:
      mesh.set_surface_override_material(0, null)


func update_mesh_type():
  Global.remove_nodes($mesh_spawn)
  var node = Global.create_plot_node(type)
  node.name = "mesh"

  if type == "farm":
    start_plant_animation(node)
  elif type == "drill":
    var animation_player = node.find_child("AnimationPlayer")
    animation_player.play("drill_rotate")
    var animation = animation_player.get_animation(animation_player.current_animation)
    animation.loop_mode = Animation.LOOP_LINEAR

    if Global.is_power_out:
      animation_player.pause()
  elif type == "oxygen pump":
    var animation_player = node.find_child("AnimationPlayer")
    animation_player.play("pump_move")
    var animation = animation_player.get_animation(animation_player.current_animation)
    animation.loop_mode = Animation.LOOP_LINEAR

    if Global.is_power_out:
      animation_player.pause()

  $mesh_spawn.add_child(node)


func _on_area_body_entered(body):
  if body.name == "player":
    Action.add_action(self)
    update_actionable_material()


func _on_area_body_exited(body):
  if body.name == "player":
    Action.remove_action(self)
    update_actionable_material()


func play_plot_added():
  if type == "farm":
    $plot_added.stream = preload("res://assets/sounds/farm_install.mp3")
    $plot_added.play()
  elif type == "solar panel":
    $plot_added.stream = preload("res://assets/sounds/solar_panel_install.mp3")
    $plot_added.play()
  elif type == "drill":
    $plot_added.stream = preload("res://assets/sounds/drill_install.mp3")
    $plot_added.play()

    if not Global.is_power_out:
      $plot_audio.stream = preload("res://assets/sounds/drill_ongoing.mp3")
      $plot_audio.volume_db = -19
      $plot_audio.play()
      $metal_spawn_timer.start()
  elif type == "oxygen pump":
    $plot_added.stream = preload("res://assets/sounds/oxygen_install.mp3")
    $plot_added.play()

    if not Global.is_power_out:
      $oxygen_spawn_timer.start()


func grab_resource():
  player.add_resource(resource)

  if resource == "food":
    Global.remove_nodes($food_spawn)
    start_plant_animation($mesh_spawn/mesh)
  elif resource == "metal":
    Global.remove_nodes($metal_spawn)
    $metal_spawn_timer.start()
  elif resource == "oxygen":
    Global.remove_nodes($oxygen_spawn)
    $oxygen_spawn_timer.start()

  resource = null



func _on_oxygen_spawn_timer_timeout():
  if Global.is_power_out or resource:
    $oxygen_spawn_timer.stop()
    return

  var node = preload("res://objs/resources/oxygen.tscn").instantiate()
  node.name = "resource"
  $oxygen_spawn.add_child(node)
  $resource_produced.stream = preload("res://assets/sounds/oxygen_tank_produced.mp3")
  $resource_produced.volume_db = -3
  $resource_produced.play()
  resource = "oxygen"
  $metal_spawn_timer.start()


func start_plant_animation(node):
  var animation_player = node.find_child("AnimationPlayer")
  animation_player.play("plant_grow_1")
  animation_player.advance(0.1)
  animation_player.pause()

  if not Global.is_power_out:
    $plant_grow_timer.start()


func _on_plant_grow_timer_timeout():
  if Global.is_power_out or resource:
    $plant_grow_timer.start()
    return

  var animation_player = $mesh_spawn/mesh/AnimationPlayer

  if animation_player.assigned_animation == 'plant_grow_1' and animation_player.current_animation_position == 0.1:
    animation_player.play('plant_grow_1')
  elif animation_player.assigned_animation == 'plant_grow_1':
    animation_player.play('plant_grow_2')
  elif animation_player.assigned_animation == 'plant_grow_2':
    animation_player.play('plant_grow_3')
  elif animation_player.assigned_animation == 'plant_grow_3':
    var node = preload("res://objs/resources/food.tscn").instantiate()
    node.name = "resource"
    $food_spawn.add_child(node)
    $resource_produced.stream = preload("res://assets/sounds/food_produced.mp3")
    $resource_produced.volume_db = -3
    $resource_produced.play()
    resource = "food"

  $plant_grow_timer.start()


func _on_metal_spawn_timer_timeout():
  if Global.is_power_out or resource:
    $metal_spawn_timer.stop()
    return

  var node = preload("res://objs/resources/metal.tscn").instantiate()
  node.name = "resource"
  $metal_spawn.add_child(node)
  $resource_produced.stream = preload("res://assets/sounds/metal_produced.mp3")
  $resource_produced.volume_db = -3
  $resource_produced.play()
  resource = "metal"
  $metal_spawn_timer.start()
