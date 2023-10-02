extends "res://objs/actionable.gd"

const ENERGY_USAGE_COST = 3

@onready var player = get_node("/root/main/player")
@onready var levels_gui = get_node("/root/main/levels_gui")


func get_action_name():
  if player.resource == "metal":
    return "deliver %s to Plots LLC" % player.resource

  return ""

func get_action_info():
  var message = "Plots LLC\n metal delivery\n "

  if Global.is_power_out:
    message += " (NO POWER - can't deliver)"

  return message


func can_perform():
  if Global.is_power_out or $mesh/resource_spawn.get_child_count() > 0:
    return false

  return player.resource == "metal"


func perform():
  if player.resource:
    var sell_node = preload("res://objs/resources/market_resource.tscn").instantiate()
    sell_node.get_node("resource").add_child(Global.create_resource_node(player.resource))
    $mesh/resource_spawn.add_child(sell_node)
    sell_node.get_node("sell_timer").start()
    player.remove_resource()

    $audio_trade_made.play()
    levels_gui.add_energy(-ENERGY_USAGE_COST)
    deliver_metal()

  Action.update_changes()


func deliver_metal():
  Global.delivered_metals += 1
  levels_gui.update_gui_objectives()


func update_changes():
  pass


func _on_area_body_entered(body):
  if body.name == "player":
    Action.add_action(self)


func _on_area_body_exited(body):
  if body.name == "player":
    Action.remove_action(self)
