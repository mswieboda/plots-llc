extends "res://objs/actionable.gd"

const ENERGY_USAGE_COST = 5

@onready var player = get_node("/root/main/player")
@onready var levels_gui = get_node("/root/main/levels_gui")

var items = []
var plot = null
var printing_plot = null
var is_valid = false


func _ready():
  $mesh/AnimationPlayer.connect("animation_finished", _on_animation_finished)


func is_stored():
  return not items.is_empty()


func stored():
  return ", ".join(items)


func is_player_holding():
  return player.resource == "metal" or player.raw_material

func player_holding():
  if player.resource == "metal":
    return player.resource
  elif player.raw_material:
    return player.raw_material
  return ""


func display_storage():
  var extra = ""

  if printing_plot:
    extra = "\nprinting: %s" % printing_plot
  elif items.size() == 2 and not is_valid:
    extra = "\ninvalid combination"

  return "inputed: %s%s" % [stored(), extra]


func get_action_name():
  if is_player_holding():
    return "input %s\n%s" % [player_holding(), display_storage()]

  if is_stored():
    return "take %s\n%s" % [items[-1], display_storage()]

  if plot:
    return "take %s" % plot

  return ""


func get_action_info():
  return "plot printer\ncombine metal and raw materials to create plots\n%s" % display_storage()


func can_perform():
  if is_player_holding():
    return items.size() < 2

  var is_player_holding_nothing = not player.plot and not player.resource and not player.raw_material

  return (not items.is_empty() or plot) and is_player_holding_nothing

func perform():
  if is_player_holding():
    items.append(player_holding())
    if player.raw_material:
      player.remove_raw_material()
    elif player.resource:
      player.remove_resource()
    $audio_store.play()

    is_valid = is_valid_recipe()

    if is_valid:
      start_printing()
  elif is_stored():
    var item = items.pop_back()
    if Global.RESOURCES.has(item):
      player.add_resource(item)
    elif Global.RAW_MATERIALS.has(item):
      player.add_raw_material(item)
    $audio_take.play()
  elif plot:
    player.add_carry_plot(plot)
    plot = null
    Global.remove_nodes($mesh/plot_spawn)
    $audio_take.play()

  Action.update_changes()


func is_valid_recipe():
  return items.has('metal') and items.size() == 2


func start_printing():
  printing_plot = null

  if items.has('seeds'):
    printing_plot = 'farm'
  elif items.has('liquid oxygen'):
    printing_plot = 'oxygen pump'
  elif items.has('solar disk'):
    printing_plot = 'solar panel'
  elif items[0] == 'metal' and items[1] == 'metal':
    printing_plot = 'drill'

  if printing_plot:
    levels_gui.add_energy(-ENERGY_USAGE_COST)
    $mesh/AnimationPlayer.play("print")
    $audio_printing.play()

func update_changes():
  pass


func _on_area_body_entered(body):
  if body.name == "player":
    Action.add_action(self)


func _on_area_body_exited(body):
  if body.name == "player":
    Action.remove_action(self)


func _on_animation_finished(animation_name):
  if animation_name != "print":
    return

  plot = printing_plot
  printing_plot = null
  items.clear()
  $mesh/plot_spawn.add_child(Global.create_carry_plot_node(plot))
  Action.update_changes()
