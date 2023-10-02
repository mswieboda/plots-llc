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
    return "store %s" % player_holding()

  if is_stored():
    return "take %s" % stored()

  return ""


func get_action_info():
  return "storage\nstore a single raw material, resource or plot"


func can_perform():
  if is_stored():
    return not is_player_holding()

  return is_player_holding()


func perform():
  if player.resource:
    resource = player.resource
    player.remove_resource()
    $mesh/resource_spawn.add_child(Global.create_resource_node(resource))
    $audio_store.play()
  elif player.plot:
    plot = player.plot
    player.remove_carry_plot()
    $mesh/plot_spawn.add_child(Global.create_carry_plot_node(plot))
    $audio_store.play()
  elif player.raw_material:
    raw_material = player.raw_material
    player.remove_raw_material()
    $mesh/raw_material_spawn.add_child(Global.create_raw_material_node(raw_material))
    $audio_store.play()
  elif resource:
    player.add_resource(resource)
    resource = null
    Global.remove_nodes($mesh/resource_spawn)
    $audio_take.play()
  elif plot:
    player.add_carry_plot(plot)
    plot = null
    Global.remove_nodes($mesh/plot_spawn)
    $audio_take.play()
  elif raw_material:
    player.add_raw_material(raw_material)
    raw_material = null
    Global.remove_nodes($mesh/raw_material_spawn)
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
