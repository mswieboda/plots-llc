extends Control


func _unhandled_input(event):
  if event.is_action_pressed("menu_quit"):
    get_tree().quit()
  elif event.is_action_pressed("menu_play"):
    get_tree().change_scene_to_file("res://scenes/main.tscn")
