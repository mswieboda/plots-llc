extends "res://objs/actionable.gd"

var is_player_actionable = false
var type = null

func get_action_name():
  if not type:
    return "place module"

  return "swap module"


func can_perform():
  return false


func perform():
  pass


func update_actionable_material():
  if is_player_actionable:
    var material = StandardMaterial3D.new()
    material.albedo_color = Color(0.3, 0.69, 0.3, 1)
    $mesh.material_override = material
  else:
    $mesh.material_override = null


func _on_area_body_entered(body):
  if body.name == "player":
    is_player_actionable = true
    update_actionable_material()
    Action.set_node(self)


func _on_area_body_exited(body):
  if body.name == "player":
    is_player_actionable = false
    update_actionable_material()
    Action.set_node(null)
