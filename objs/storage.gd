extends "res://objs/actionable.gd"

@export_enum("food", "oxygen") var type: String = "food"
@onready var player = get_node("/root/main/player")

func _ready():
  var material = null

  if type == "food":
    material = preload("res://assets/materials/farm.tres")
  elif type == "oxygen":
    material = preload("res://assets/materials/oxygen_pump.tres")

  $mesh.material_override = material


func get_action_name():
  return "store %s" % player.resource if player.resource else ""


func get_action_info():
  return "Store %s" % type


func can_perform():
  return player.resource == type


func perform():
  pass


func update_changes():
  pass


func _on_area_body_entered(body):
  if body.name == "player":
    Action.add_action(self)


func _on_area_body_exited(body):
  if body.name == "player":
    Action.remove_action(self)
