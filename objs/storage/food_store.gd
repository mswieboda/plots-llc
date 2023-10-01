extends "res://objs/actionable.gd"

const TYPE = "food"
@onready var player = get_node("/root/main/player")

var count = 0


func display_storage():
  return "%s: %d" % [TYPE, count]


func get_action_name():
  if player.resource:
    return "store %s\n%s" % [TYPE, display_storage()]

  if count > 0:
    return "take %s\n%s" % [TYPE, display_storage()]

  return ""


func get_action_info():
  return "%s storage\n%s" % [TYPE, display_storage()]


func can_perform():
  return player.resource == TYPE or count > 0


func perform():
  if player.resource:
    player.remove_resource()
    count += 1
    $audio_store.play()
  else:
    count -= 1
    player.add_resource(TYPE)
    $audio_take.play()

  Action.update_changes()


func update_changes():
  pass


func _on_area_body_entered(body):
  if body.name == "player":
    Action.add_action(self)


func _on_area_body_exited(body):
  if body.name == "player":
    Action.remove_action(self)
