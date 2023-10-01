extends Node

var is_game_over = false
@onready var player = get_node('/root/main/player')

func end_game():
  var game_over_timer = Timer.new()
  game_over_timer.name = "game_over_timer"
  game_over_timer.timeout.connect(_on_game_over_timer_timeout)
  game_over_timer.wait_time = 3
  add_child(game_over_timer)
  game_over_timer.start()


  is_game_over = true
  player.dead = true


func remove_nodes(parent: Node3D):
  for node in parent.get_children():
    parent.remove_child(node)
    node.queue_free()


func _on_game_over_timer_timeout():
  # TODO: implement an actual UI menu for this
  OS.alert("Please exit the game and restart to start over.", "Game Over")
