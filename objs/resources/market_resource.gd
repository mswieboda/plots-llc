extends CharacterBody3D

const MAX_DISTANCE = 10

var initial_y = 0
var bought_resource = null

func _physics_process(_delta):
  if velocity.y != 0:
    move_and_slide()

  if velocity.y > 0 and position.y - initial_y >= MAX_DISTANCE:
    sell_done()

  if velocity.y < 0 and position.y - initial_y <= -MAX_DISTANCE:
    buy_done()


func _on_sell_timer_timeout():
  initial_y = position.y
  velocity.y = 10


func buy_start(resource):
  bought_resource = resource
  position.y = MAX_DISTANCE
  initial_y = MAX_DISTANCE
  velocity.y = -10


func sell_done():
  velocity.y = 0
  get_parent().remove_child(self)
  queue_free()
  Action.update_changes()

func buy_done():
  velocity.y = 0

  var market_terminal_node = get_parent().get_parent().get_parent()

  if market_terminal_node.has_method('add_bought_resource'):
    market_terminal_node.add_bought_resource(bought_resource)
