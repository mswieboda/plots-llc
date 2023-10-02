extends "res://objs/actionable.gd"

@onready var player = get_node("/root/main/player")

var items = []
var plot = null

func stored():
  return ", ".join(items)


func display_storage():
  return "inputed: %s" % stored()


func get_action_name():
  if player.raw_material:
    return "input %s\n%s" % [player.raw_material or player.resource, display_storage()]

  if not items.is_empty():
    return "take %s\n%s" % [items[-1], display_storage()]

  if plot:
    return "take %s" % plot

  return ""


func get_action_info():
  return "plot printer\ncombine metal and raw materials to create plots\n%s" % display_storage()


func can_perform():
  return not player.plot and (player.resource or not items.is_empty())

func perform():
  if player.raw_material or player.resource:
    items.append(player.raw_material or player.resource)
    if player.raw_material:
      player.remove_raw_material()
    elif player.resource:
      player.remove_resource()
    $audio_store.play()

    # TODO: check recipes here, timer to create plots
    # TODO: check recipes here, timer to create plots
    # TODO: check recipes here, timer to create plots

  elif not items.is_empty():
    var resource = items.pop_back()
    player.add_resource(resource)
    $audio_take.play()
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
