extends "res://objs/actionable.gd"

@export_enum("food", "oxygen") var type: String = "food"
@onready var player = get_node("/root/main/player")

var count = 0

func _ready():
  var material = null

  if type == "food":
    material = preload("res://assets/materials/farm.tres")
  elif type == "oxygen":
    material = preload("res://assets/materials/oxygen_pump.tres")

  $mesh.material_override = material


func display_storage():
  return "%s: %d" % [type, count]


func get_action_name():
  if player.resource:
    return "store %s\n%s" % [type, display_storage()]

  if count > 0:
    return "take %s\n%s" % [type, display_storage()]

  return ""


func get_action_info():
  return "%s storage\n%s" % [type, display_storage()]


func can_perform():
  return player.resource == type or count > 0


func perform():
  if player.resource:
    player.remove_resource()
    count += 1
  else:
    count -= 1
    player.add_resource(type)

  Action.update_changes()


func update_changes():
  pass


func _on_area_body_entered(body):
  if body.name == "player":
    Action.add_action(self)


func _on_area_body_exited(body):
  if body.name == "player":
    Action.remove_action(self)
