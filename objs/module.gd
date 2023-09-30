extends "res://objs/actionable.gd"

var is_player_actionable = false
var type = null

@onready var player = get_node("/root/main/player")

func get_action_name():
  if type and player.module:
    return "swap module"

  return "place module" if player.module else ""


func can_perform():
  return is_player_actionable and player.module


func perform():
  type = player.module
  player.remove_carry_module()
  update_type_material()


func update_actionable_material():
  var action_node = Action.action_node()
  if is_player_actionable and action_node and action_node.name == name:
    var material = StandardMaterial3D.new()
    material.albedo_color = Color(1, 1, 1, 0.069)
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    $mesh.material_overlay = material
  else:
    $mesh.material_overlay = null


func update_type_material():
  if type == "farm":
    var material = preload("res://assets/materials/farm.tres")
    $mesh.material_override = material


func _on_area_body_entered(body):
  if body.name == "player":
    is_player_actionable = true
    Action.add_action(self)
    update_actionable_material()


func _on_area_body_exited(body):
  if body.name == "player":
    is_player_actionable = false
    Action.remove_action(self)
    update_actionable_material()
