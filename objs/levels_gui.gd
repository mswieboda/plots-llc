extends CanvasLayer

var energy = 100
var oxygen = 100
var food = 100

const WARNING_LEVEL = 25

@onready var hbox = $margin/hbox

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

  if value <= WARNING_LEVEL:
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

func _on_energy_timer_timeout():
  energy -= 0.1 # times number of modules
  update_label('energy', energy)


func _on_oxygen_timer_timeout():
  oxygen -= 0.1
  update_label('oxygen', oxygen)


func _on_food_timer_timeout():
  food -= 5
  update_label('food', food)
