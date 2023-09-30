extends "res://objs/actionable.gd"

var type = null

@onready var player = get_node("/root/main/player")

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
    update_type_material()
  elif type:
    player.add_carry_plot(type)
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
