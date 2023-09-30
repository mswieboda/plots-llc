extends "res://objs/actionable.gd"

const TYPE: String = "oxygen"
@onready var player = get_node("/root/main/player")
@onready var levels_gui = get_node("/root/main/levels_gui")


func get_action_name():
  if player.resource:
    return "inject %s" % TYPE

  return ""


func get_action_info():
  return "inject %s" % TYPE


func can_perform():
  return player.resource == TYPE


func perform():
  if player.resource != TYPE:
    return

  player.remove_resource()
  levels_gui.add_oxygen(5)
  Action.update_changes()


func _on_area_body_entered(body):
  if body.name == "player":
    Action.add_action(self)


func _on_area_body_exited(body):
  if body.name == "player":
    Action.remove_action(self)
