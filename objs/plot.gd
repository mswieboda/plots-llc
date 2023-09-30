extends "res://objs/actionable.gd"

var type = null

@onready var player = get_node("/root/main/player")


func _ready():
  update_mesh_type()


func get_action_name():
  if type:
    if not player.resource and player.plot and player.plot != type:
      return "replace with %s" % player.plot
    else:
      return "remove %s" % type if not player.plot else ""

  return "plot %s" % player.plot if player.plot else ""


func can_perform():
  if not Action.is_action_node(self) or player.resource:
    return false

  if player.plot:
    return player.plot != type

  return !!type


func perform():
  if player.plot:
    type = player.plot
    player.remove_carry_plot()
    update_mesh_type()
  elif type:
    player.add_carry_plot(type)
    type = null


func update_changes():
  update_actionable_material()
  update_mesh_type()


func update_actionable_material():
  # TODO: drill can't be highlighted right now
  if type == "drill" or not $mesh_spawn/mesh.has_node('module'):
    return

  if Action.is_action_node(self) and can_perform():
    var material = StandardMaterial3D.new()
    material.albedo_color = Color(1, 1, 1, 0.069)
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    $mesh_spawn/mesh/module.set_surface_override_material(0, material)
  else:
    $mesh_spawn/mesh/module.set_surface_override_material(0, null)


func update_mesh_type():
  var mesh = preload("res://objs/plots/default.tscn")

  if type == "farm":
    mesh = preload("res://assets/models/plots/farm/plant_module.gltf")
  elif type == "drill":
    mesh = preload("res://assets/models/plots/drill/drill_module.gltf")

  Global.remove_nodes($mesh_spawn)
  var node = mesh.instantiate()
  node.name = "mesh"

#  if type == "drill":
#    var material = preload('res://assets/materials/drill.tres')
#    node.get_node('module').material_overlay = material
  if type == "oxygen pump":
    var material = preload('res://assets/materials/oxygen_pump.tres')
    node.get_node('module').material_overlay = material
  elif type == "generator":
    var material = preload('res://assets/materials/generator.tres')
    node.get_node('module').material_overlay = material

  $mesh_spawn.add_child(node)


func _on_area_body_entered(body):
  if body.name == "player":
    Action.add_action(self)
    update_actionable_material()


func _on_area_body_exited(body):
  if body.name == "player":
    Action.remove_action(self)
    update_actionable_material()
