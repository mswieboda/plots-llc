extends CanvasLayer

var energy = 100
var oxygen = 100
var food = 100

const WARNING_LEVEL = 25
const ENERGY_COST_BASE = 0.05
const ENERGY_COST_PLOT = 0.1
const ENERGY_GENERATED = 0.35

@onready var hbox = $margin/hbox
@onready var plots = get_parent().get_node('plots')

func _ready():
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
  var energy_output = 0

  for plot in plots.get_children():
    # TODO: bonus for adjacent generators
    if plot.type == "generator":
      energy_output += 1

  var num_plots = plots.get_children().filter(func(plot): return !!plot.type).size()

  energy += ENERGY_GENERATED * energy_output
  energy -= ENERGY_COST_BASE + ENERGY_COST_PLOT * num_plots
  energy = clamp(energy, 0, 100)
  update_label('energy', energy)


func _on_oxygen_timer_timeout():
  oxygen -= 0.1
  update_label('oxygen', oxygen)


func _on_food_timer_timeout():
  food -= 5
  update_label('food', food)
