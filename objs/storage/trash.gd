extends "res://objs/actionable.gd"

@onready var player = get_node("/root/main/player")

var plot = null
var resource = null
var raw_material = null

func is_stored():
  return plot or resource or raw_material


func stored():
  if plot:
    return plot
  elif resource:
    return resource
  elif raw_material:
    return raw_material
  return ""


func is_player_holding():
  return player.plot or player.resource or player.raw_material

func player_holding():
  if player.plot:
    return player.plot
  elif player.resource:
    return player.resource
  elif player.raw_material:
    return player.raw_material
  return ""


func get_action_name():
  if is_player_holding():
    return "destroy %s" % player_holding()

  return ""


func get_action_info():
  if is_stored():
    return "destroying %s" % stored()
  else:
    return "trash\ndestroy raw materials, resources or plots"


func can_perform():
  return not is_stored() and is_player_holding()


func perform():
  if player.resource:
    resource = player.resource
    player.remove_resource()
    $mesh/resource_spawn.add_child(Global.create_resource_node(resource))
  elif player.plot:
    plot = player.plot
    player.remove_carry_plot()
    $mesh/plot_spawn.add_child(Global.create_carry_plot_node(plot))
  elif player.raw_material:
    raw_material = player.raw_material
    player.remove_raw_material()
    $mesh/raw_material_spawn.add_child(Global.create_raw_material_node(raw_material))

  $destroy_timer.start()
  $audio_store.play()
  Action.update_changes()


func update_changes():
  pass


func _on_area_body_entered(body):
  if body.name == "player":
    Action.add_action(self)


func _on_area_body_exited(body):
  if body.name == "player":
    Action.remove_action(self)


func _on_destroy_timer_timeout():
  plot = null
  resource = null
  raw_material = null
  Global.remove_nodes($mesh/resource_spawn)
  Global.remove_nodes($mesh/plot_spawn)
  Global.remove_nodes($mesh/raw_material_spawn)
  $audio_destroy.play()
