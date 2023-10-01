extends "res://objs/actionable.gd"

@onready var player = get_node("/root/main/player")

var resources = []
var plot = null

func stored():
  return ", ".join(resources)


func display_storage():
  return "inputed: %s" % stored()


func get_action_name():
  if player.resource:
    return "input %s\n%s" % [player.resource, display_storage()]

  if not resources.is_empty():
    return "take %s\n%s" % [resources[-1], display_storage()]

  if plot:
    return "take %s" % plot

  return ""


func get_action_info():
  return "plot printer\ninput resources to create plots\n%s" % display_storage()


func can_perform():
  return not player.plot and (player.resource or not resources.is_empty())

func perform():
  if player.resource:
    resources.append(player.resource)

    var node = null

    if player.resource == "food":
      node = preload("res://objs/resources/food.tscn")
    elif player.resource == "oxygen":
      node = preload("res://objs/resources/oxygen.tscn")
    elif player.resource == "metal":
      node = preload("res://objs/resources/metal.tscn")
    elif player.resource == "solar panel":
      node = preload("res://objs/resources/solar_panel.tscn")

    $mesh/resource_spawn.add_child(node.instantiate())
    player.remove_resource()
    $audio_store.play()
  elif not resources.is_empty():
    var resource = resources.pop_back()

    player.add_resource(resource)
    var node = $mesh/resource_spawn.get_child(-1)
    $mesh/resource_spawn.remove_child(node)
    node.queue_free()
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
