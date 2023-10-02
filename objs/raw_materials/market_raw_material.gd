extends CharacterBody3D

const MAX_DISTANCE = 10

var initial_y = 0
var bought_raw_material = null

func _physics_process(_delta):
  if velocity.y != 0:
    move_and_slide()

  if velocity.y < 0 and position.y - initial_y <= -MAX_DISTANCE:
    buy_done()


func buy_start(raw_material):
  bought_raw_material = raw_material
  position.y = MAX_DISTANCE
  initial_y = MAX_DISTANCE
  velocity.y = -10


func buy_done():
  velocity.y = 0

  var market_terminal_node = get_parent().get_parent().get_parent()

  if market_terminal_node.has_method('add_bought_raw_material'):
    market_terminal_node.add_bought_raw_material(bought_raw_material)
