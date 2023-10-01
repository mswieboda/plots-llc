extends Node

@onready var player = get_node('/root/main/player')
@onready var sun = get_node('/root/main/sun')

var is_game_over = false
var is_power_shutdown = false

func end_game():
  var game_over_timer = Timer.new()
  game_over_timer.name = "game_over_timer"
  game_over_timer.timeout.connect(_on_game_over_timer_timeout)
  game_over_timer.wait_time = 3
  game_over_timer.autostart = true
  add_child(game_over_timer)

  is_game_over = true
  player.dead = true


func remove_nodes(parent: Node3D):
  for node in parent.get_children():
    parent.remove_child(node)
    node.queue_free()


func _on_game_over_timer_timeout():
  # TODO: implement an actual UI menu for this
  remove_child($game_over_timer)
  $game_over_timer.queue_free()
  OS.alert("Please exit the game and restart to start over.", "Game Over")


func power_shutdown():
  is_power_shutdown = true
  sun.light_energy = 0.3


func power_resume():
  is_power_shutdown = false
  sun.light_energy = 1
