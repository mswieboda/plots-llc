extends CanvasLayer

var energy = 100
var oxygen = 100
var food = 100

const WARNING_LEVEL = 25

const ENERGY_COST_BASE = 0.05
const ENERGY_COST_PLOT = 0.1
const ENERGY_GENERATED = 0.36
const POWER_RESUME_LEVEL = 1

const OXYGEN_DRAIN = -0.1
const FOOD_DRAIN = -0.15

@onready var hbox = $margin/vbox/hbox
@onready var objectives = $margin/vbox/objectives
@onready var plots = get_node('/root/main/rooms/plots')
@onready var player = get_node('/root/main/player')
@onready var sun = get_node('/root/main/sun')
@onready var living_room = get_node('/root/main/rooms/living_room')

var is_game_over = false
var is_game_won = false
var end_game_reason = ""
var start_time = 0
var end_time = 0

func _ready():
  start_time = Time.get_ticks_msec()
  update_gui()


func _unhandled_input(event):
  if $game_over_menu.visible:
    if event.is_action_pressed("menu_quit"):
      get_tree().quit()
    elif event.is_action_pressed("menu_restart"):
      Action.actions.clear()
      get_tree().change_scene_to_file("res://scenes/splash.tscn")
      get_tree().unload_current_scene()


func update_gui_objectives():
  var message = "Objectives:\n"
  message += "- metals delivered: "
  message += str(Global.delivered_metals) + "/" + str(Global.delivered_metals_objective)
  objectives.text = message

  if not is_game_won and Global.delivered_metals >= Global.delivered_metals_objective:
    is_game_won = true
    stop_game()
    player.celebrate()
    $game_won_timer.start()


func update_gui():
  update_gui_objectives()
  update_label('energy', energy)
  update_label('oxygen', oxygen)
  update_label('food', food)


func update_label(type: String, value):
  var bar = hbox.get_node(type) as ProgressBar

  bar.value = value

  var stylebox = bar.get_theme_stylebox("fill")

  if value < WARNING_LEVEL:
    stylebox.border_color = Color(1, 0, 0, 1)
    stylebox.border_width_left = 3
    stylebox.border_width_top = 3
    stylebox.border_width_right = 3
    stylebox.border_width_bottom = 3

  else:
    stylebox.border_color = Color(1, 1, 1, 1)
    stylebox.border_width_left = 1
    stylebox.border_width_top = 1
    stylebox.border_width_right = 1
    stylebox.border_width_bottom = 1

  change_music_checks()


func change_music_checks():
  if energy < WARNING_LEVEL or oxygen < WARNING_LEVEL or food < WARNING_LEVEL:
    if not $music_stressed.playing:
      $music_chill.stop()
      $music_stressed.play()
  elif not $music_chill.playing:
    $music_stressed.stop()
    $music_chill.play()


func _on_energy_timer_timeout():
  var energy_to_add = 0

  for plot in plots.get_children():
    # TODO: bonus for adjacent solar panels
    if plot.type == "solar panel":
      energy_to_add += 1

  var num_plots = plots.get_children().filter(func(plot): return !!plot.type).size()

  energy_to_add *= ENERGY_GENERATED
  energy_to_add -= ENERGY_COST_BASE + ENERGY_COST_PLOT * num_plots

  add_energy(energy_to_add)


func _on_oxygen_timer_timeout():
  add_oxygen(OXYGEN_DRAIN)


func _on_food_timer_timeout():
  add_food(FOOD_DRAIN)


func add_energy(value):
  energy += value
  energy = clamp(energy, 0, 100)
  update_label('energy', energy)

  if energy <= 0 and not Global.is_power_out:
    power_shutdown()
  elif Global.is_power_out and energy > POWER_RESUME_LEVEL:
    power_resume()

func add_oxygen(value):
  oxygen += value
  oxygen = clamp(oxygen, 0, 100)
  update_label('oxygen', oxygen)

  if oxygen <= 0 and not is_game_over:
    $audio_gasping.play()
    end_game_reason = "suffocated"
    end_game()

func add_food(value):
  food += value
  food = clamp(food, 0, 100)
  update_label('food', food)

  if food <= 0 and not is_game_over:
    $audio_starvation.play()
    end_game_reason = "starved"
    end_game()


func stop_game():
  end_time = Time.get_ticks_msec()
  $game_over_timer.start()
  $music_stressed.stop()
  $music_chill.stop()

func end_game():
  stop_game()
  is_game_over = true
  player.die()


func _on_game_over_timer_timeout():
  var reason = "Oh no, you %s and died." % end_game_reason
  var lasted = "Lasted: %.2f min" % ((end_time - start_time) / 1000.0 / 60.0)
  var delivered = "Metal delivered: " + str(Global.delivered_metals) + "/" + str(Global.delivered_metals_objective)
  var message = "%s\n%s\n%s" % [reason, lasted, delivered]

  $game_over_menu/vbox/title.text = "Game Over!"
  $game_over_menu/vbox/message.text = message
  $game_over_menu.show()


func power_shutdown():
  $audio_power_shutdown.play()
  sun.light_energy = 0.03
  Global.is_power_out = true
  stop_plots()
  Action.update_changes()


func power_resume():
  sun.light_energy = 1
  Global.is_power_out = false
  start_plots()
  Action.update_changes()


func stop_plots():
  for plot in plots.get_children():
    if plot.type == "farm":
      plot.get_node('mesh_spawn/mesh/AnimationPlayer').pause()
      plot.get_node('plant_grow_timer').stop()
    elif plot.type == "drill":
      plot.get_node('mesh_spawn/mesh/AnimationPlayer').pause()
      plot.get_node('metal_spawn_timer').stop()
      plot.get_node('plot_audio').stream_paused = true
    elif plot.type == "O2 pump":
      plot.get_node('mesh_spawn/mesh/AnimationPlayer').pause()
      plot.get_node('oxygen_spawn_timer').stop()

func start_plots():
  for plot in plots.get_children():
    if plot.type == "farm":
      plot.get_node('mesh_spawn/mesh/AnimationPlayer').play()
      plot.get_node('plant_grow_timer').start()
    elif plot.type == "drill":
      plot.get_node('mesh_spawn/mesh/AnimationPlayer').play()
      plot.get_node('metal_spawn_timer').start()
      plot.get_node('plot_audio').stream_paused = false
    elif plot.type == "O2 pump":
      plot.get_node('mesh_spawn/mesh/AnimationPlayer').play()
      plot.get_node('oxygen_spawn_timer').start()


func _on_game_won_timer_timeout():
  var reason = "Congrats, objectives completed sustainably."
  var lasted = "Finished in: %.2f min" % ((end_time - start_time) / 1000.0 / 60.0)
  var delivered = "Metal delivered: " + str(Global.delivered_metals) + "/" + str(Global.delivered_metals_objective)
  var message = "%s\n%s\n%s" % [reason, lasted, delivered]

  $game_over_menu/vbox/title.text = "You Won!"
  $game_over_menu/vbox/message.text = message
  $game_over_menu.show()
