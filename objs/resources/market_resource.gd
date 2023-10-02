extends CharacterBody3D

const MAX_DISTANCE = 10

var initial_y = 0

func _physics_process(_delta):
  if velocity.y != 0:
    move_and_slide()

  if velocity.y > 0 and position.y - initial_y >= MAX_DISTANCE:
    sell_done()


func _on_sell_timer_timeout():
  initial_y = position.y
  velocity.y = 10


func sell_done():
  velocity.y = 0
  get_parent().remove_child(self)
  queue_free()
  Action.update_changes()
