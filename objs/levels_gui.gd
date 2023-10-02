extends CanvasLayer

var energy = 100
var oxygen = 100
var food = 100

const WARNING_LEVEL = 25

const ENERGY_COST_BASE = 0.05
const ENERGY_COST_PLOT = 0.1
const ENERGY_GENERATED = 0.35

const OXYGEN_DRAIN = -0.1
const FOOD_DRAIN = -5

@onready var hbox = $margin/hbox
@onready var plots = get_node('/root/main/rooms/plots')
@onready var player = get_node('/root/main/player')
@onready var sun = get_node('/root/main/sun')

var is_game_over = false
var is_power_shutdown = false
var end_game_reason = ""
var start_time = 0
var end_time = 0

func _ready():
  start_time = Time.get_ticks_msec()
  update_gui()


func update_gui():
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

  if energy <= 0 and not is_power_shutdown:
    $audio_power_shutdown.play()
    power_shutdown()
  elif is_power_shutdown and energy > 0:
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
    # TODO: audio death sound
    $audio_starvation.play()
    end_game_reason = "starved"
    end_game()


func end_game():
  end_time = Time.get_ticks_msec()
  $game_over_timer.start()
  $music_stressed.stop()
  $music_chill.stop()

  is_game_over = true
  player.die()


func _on_game_over_timer_timeout():
  # TODO: implement an actual UI menu for this
  var reason = "Oh no, you %s and died." % end_game_reason
  var funny = "Blame it on the limited plots in space Plots, LLC provided you."
  var stats = "Lasted: %.2f min" % ((end_time - start_time) / 1000.0 / 60.0)
  var instructions = "Please exit the game and restart to start over."
  var message = "%s\n%s\n%s\n%s" % [reason, funny, stats, instructions]
  OS.alert(message, "Game Over")


func power_shutdown():
  is_power_shutdown = true
  sun.light_energy = 0.03


func power_resume():
  is_power_shutdown = false
  sun.light_energy = 1
