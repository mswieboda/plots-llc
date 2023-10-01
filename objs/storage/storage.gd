extends "res://objs/actionable.gd"

@onready var player = get_node("/root/main/player")

var plot = null
var resource = null


func stored():
  var item = plot if plot else resource

  return item if item else ""


func player_holding():
  return player.plot if player.plot else player.resource


func display_storage():
  return "stored: %s" % stored()


func get_action_name():
  if player_holding():
    return "store %s" % player_holding()

  if plot or resource:
    return "take %s" % stored()

  return ""


func get_action_info():
  return "storage\n%s" % display_storage()


func can_perform():
  if plot or resource:
    return not player.plot and not player.resource

  return !!player_holding()


func perform():
  if player.resource:
    resource = player.resource
    player.remove_resource()

    var node = null

    if resource == "food":
      node = preload("res://objs/resources/food.tscn")
    elif resource == "oxygen":
      node = preload("res://objs/resources/oxygen.tscn")
    elif resource == "metal":
      node = preload("res://objs/resources/metal.tscn")

    $mesh/resource_spawn.add_child(node.instantiate())
    $audio_store.play()
  elif player.plot:
    plot = player.plot
    player.remove_carry_plot()

    var carry_plot_scene = preload("res://objs/plots/carry_default.tscn")

    if plot == "farm":
      carry_plot_scene = preload("res://assets/models/plots/farm/plant.gltf")
    elif plot == "drill":
      carry_plot_scene = preload("res://assets/models/plots/drill/drill.gltf")
    elif plot == "solar panel":
      carry_plot_scene = preload("res://assets/models/plots/solar_panel/solar_module_joined.gltf")
    elif plot == "oxygen pump":
      carry_plot_scene = preload("res://assets/models/plots/o2/o2.gltf")

    $mesh/plot_spawn.add_child(carry_plot_scene.instantiate())
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

  Action.update_changes()


func update_changes():
  pass


func _on_area_body_entered(body):
  if body.name == "player":
    Action.add_action(self)


func _on_area_body_exited(body):
  if body.name == "player":
    Action.remove_action(self)
