extends "res://objs/actionable.gd"

const ENERGY_USAGE_COST = 5
@onready var player = get_node("/root/main/player")
@onready var levels_gui = get_node("/root/main/levels_gui")
var resource = null


func get_action_name():
  if player.resource:
    # TODO: change to sell when money is implement
    # return "sell %s" % player.resource
    return "donate %s" % player.resource

  if resource:
    return "take %s" % resource

  # TODO: after pressing E, prompt with a buy/upgrade menu
  # return "buy resources or upgrades"
  return "get free solar panel resource"

func get_action_info():
  # TODO: remove DONTATION MODE when money implemented
  return "market terminal (DONATION MODE)\nbuy/sell resources and upgrades"


func can_perform():
  return $mesh/market_resource_spawn.get_child_count() == 0 and (resource or player.resource or not player.plot)


# TODO: still WIP on currency, and buying things
func perform():
  if player.resource:
    var market_resource_node = preload("res://objs/resources/market_resource.tscn").instantiate()
    market_resource_node.get_node("resource").add_child(create_resource_node(player.resource))
    $mesh/market_resource_spawn.add_child(market_resource_node)
    market_resource_node.get_node("sell_timer").start()
    player.remove_resource()
    $audio_store.play()
    levels_gui.add_energy(-ENERGY_USAGE_COST)
  elif resource:
    player.add_resource(resource)
    resource = null
    Global.remove_nodes($mesh/resource_spawn)
    $audio_take.play()
  else:
    # we're buying
    # TODO: use a menu to determine what to buy, display prices, etc
    var choice = "solar panel"
    var market_resource_node = preload("res://objs/resources/market_resource.tscn").instantiate()
    market_resource_node.get_node("resource").add_child(create_resource_node(choice))
    $mesh/market_resource_spawn.add_child(market_resource_node)
    market_resource_node.buy_start(choice)
    player.remove_resource()
    $audio_take.play()
    levels_gui.add_energy(-ENERGY_USAGE_COST)

  Action.update_changes()


func add_bought_resource(bought_resource):
  resource = bought_resource
  Global.remove_nodes($mesh/market_resource_spawn)
  $mesh/resource_spawn.add_child(create_resource_node(resource))
  Action.update_changes()


func create_resource_node(type):
  var node = null

  if type == "food":
    node = preload("res://objs/resources/food.tscn")
  elif type == "oxygen":
    node = preload("res://objs/resources/oxygen.tscn")
  elif type == "metal":
    node = preload("res://objs/resources/metal.tscn")
  elif type == "solar panel":
    node = preload("res://objs/resources/solar_panel.tscn")

  return node.instantiate()


func update_changes():
  pass


func _on_area_body_entered(body):
  if body.name == "player":
    Action.add_action(self)


func _on_area_body_exited(body):
  if body.name == "player":
    Action.remove_action(self)
