extends "res://objs/actionable.gd"

@onready var player = get_node("/root/main/player")

var items = []
var plot = null


func stored():
  return ", ".join(items)


func player_holding():
  return player.plot if player.plot else player.resource


func display_storage():
  return "stored: %s" % stored()


func get_action_name():
  if player_holding():
    return "store %s" % player_holding()

  if not items.is_empty():
    return "take %s" % stored()

  if plot:
    return "take %s" % plot

  return ""


func get_action_info():
  return "plot printer\nstore resources to create plots\n%s" % display_storage()


func can_perform():
  if not items.is_empty():
    return not player.plot or not player.resource

  return !!player_holding()


func perform():
  if player.resource:
    items.append(player.resource)

    var node = null

    if player.resource == "food":
      node = preload("res://objs/resources/food.tscn")
    elif player.resource == "oxygen":
      node = preload("res://objs/resources/oxygen.tscn")
    elif player.resource == "metal":
      node = preload("res://objs/resources/metal.tscn")

    $mesh/resource_spawn.add_child(node.instantiate())
    player.remove_resource()
    $audio_store.play()
  elif plot:
    player.add_carry_plot(plot)
    plot = null
    Global.remove_nodes($mesh/plot_spawn)
    $audio_take.play()

  Action.update_changes()


func update_changes():
  pass


func _on_area_body_entered(body):
  if body.name == "player":
    Action.add_action(self)


func _on_area_body_exited(body):
  if body.name == "player":
    Action.remove_action(self)
