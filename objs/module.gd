extends "res://objs/actionable.gd"

var type = null

@onready var player = get_node("/root/main/player")

func get_action_name():
  if type:
    if player.module && player.module != type:
      return "swap module to %s" % player.module
    else:
      return "remove module %s" % type if not player.module else ""

  return "place module %s" % player.module if player.module else ""


func can_perform():
  if not Action.is_action_node(self):
    return false

  if player.module:
    return player.module != type

  return !!type


func perform():
  if player.module:
    type = player.module
    player.remove_carry_module()
    update_type_material()
  elif type:
    player.add_carry_module(type)
    type = null


func update_changes():
  update_actionable_material()
  update_type_material()


func update_actionable_material():
  if Action.is_action_node(self) and can_perform():
    var material = StandardMaterial3D.new()
    material.albedo_color = Color(1, 1, 1, 0.069)
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    $mesh.material_overlay = material
  else:
    $mesh.material_overlay = null


func update_type_material():
  var material = null

  if type == "farm":
    material = preload("res://assets/materials/farm.tres")
  elif type == "drill":
    material = preload("res://assets/materials/drill.tres")
  elif type == "oxygen pump":
    material = preload("res://assets/materials/oxygen_pump.tres")
  elif type == "generator":
    material = preload("res://assets/materials/generator.tres")

  $mesh.material_override = material


func _on_area_body_entered(body):
  if body.name == "player":
    Action.add_action(self)
    update_actionable_material()


func _on_area_body_exited(body):
  if body.name == "player":
    Action.remove_action(self)
    update_actionable_material()
