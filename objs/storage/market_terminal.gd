extends "res://objs/actionable.gd"

const ENERGY_USAGE_COST = 5

@onready var player = get_node("/root/main/player")
@onready var levels_gui = get_node("/root/main/levels_gui")
var raw_material = null
var trade_raw_material = "solar disk"


func _unhandled_input(event):
  if event.is_action_pressed("cycle"):
    cycle_trade_selection()


func cycle_trade_selection():
  var index = Global.RAW_MATERIALS.find(trade_raw_material)
  var next_index = index + 1

  if next_index >= Global.RAW_MATERIALS.size():
    next_index = 0

  trade_raw_material = Global.RAW_MATERIALS[next_index]
  Action.update_changes()


func display_instructions():
  return "press [TAB] to cycle:\n%s" % display_trade_raw_materials()


func display_trade_raw_materials():
  return "\n".join(Global.RAW_MATERIALS.map(func(r): return "-<( %s )>-" % r if r == trade_raw_material else r))


func get_action_name():
  if player.resource:
    return "trade %s for %s\n%s" % [player.resource, trade_raw_material, display_instructions()]

  if raw_material:
    return "take %s" % raw_material

  return ""

func get_action_info():
  var message = "market\ntrade metal for raw materials"

  if Global.is_power_out:
    message += " (NO POWER - can't trade)"

  return message


func can_perform():
  if Global.is_power_out or $mesh/market_raw_material_spawn.get_child_count() > 0:
    return false

  if raw_material:
    return not player.raw_material and not player.resource and not player.plot

  return player.resource == "metal"


func perform():
  if player.resource:
    var sell_node = preload("res://objs/resources/market_resource.tscn").instantiate()
    sell_node.get_node("resource").add_child(Global.create_resource_node(player.resource))
    $mesh/market_resource_spawn.add_child(sell_node)
    sell_node.get_node("sell_timer").start()
    player.remove_resource()

    var buy_node = preload("res://objs/raw_materials/market_raw_material.tscn").instantiate()
    buy_node.get_node("raw_material").add_child(Global.create_raw_material_node(trade_raw_material))
    $mesh/market_raw_material_spawn.add_child(buy_node)
    buy_node.buy_start(trade_raw_material)

    $audio_store.play()
    levels_gui.add_energy(-ENERGY_USAGE_COST)
  elif raw_material:
    player.add_raw_material(raw_material)
    raw_material = null
    Global.remove_nodes($mesh/raw_material_spawn)
    $audio_take.play()

  Action.update_changes()


func add_bought_raw_material(bought_raw_material):
  raw_material = bought_raw_material
  Global.remove_nodes($mesh/market_raw_material_spawn)
  $mesh/raw_material_spawn.add_child(Global.create_raw_material_node(raw_material))
  $audio_trade_made.play()
  Action.update_changes()


func update_changes():
  pass


func _on_area_body_entered(body):
  if body.name == "player":
    Action.add_action(self)


func _on_area_body_exited(body):
  if body.name == "player":
    Action.remove_action(self)
