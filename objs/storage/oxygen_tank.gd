extends "res://objs/actionable.gd"

const TYPE: String = "O2 tank"
const ENERGY_USAGE_COST = 1
const OXYGEN_INCREASE = 6

@onready var player = get_node("/root/main/player")
@onready var levels_gui = get_node("/root/main/levels_gui")


func get_action_name():
  if player.resource:
    return "deposit %s" % TYPE

  return ""


func get_action_info():
  var message = "O2 distributor\n "

  if Global.is_power_out:
    message += "(NO POWER - can't inject)"

  return message


func can_perform():
  return not Global.is_power_out and player.resource == TYPE


func perform():
  if player.resource != TYPE:
    return

  player.remove_resource()
  levels_gui.add_oxygen(OXYGEN_INCREASE)
  $mesh/AnimationPlayer.play("pump_action")
  $audio_consumed.play()
  levels_gui.add_energy(-ENERGY_USAGE_COST)
  Action.update_changes()


func _on_area_body_entered(body):
  if body.name == "player":
    Action.add_action(self)


func _on_area_body_exited(body):
  if body.name == "player":
    Action.remove_action(self)
