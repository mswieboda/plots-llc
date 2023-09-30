extends Node

var action_nodes = []

@onready var action_label = get_node('/root/main/player/gui/margin/action_label')

func action_node():
  if action_nodes.is_empty():
    return null

  return action_nodes[-1]

func get_display() -> String:


  if can_perform():
    var action_node = action_node()

    if action_node and action_node.has_method("get_action_name"):
      return "Press [E] to " + action_node.get_action_name()

  return " "


func add_action(n):
  action_nodes.append(n)
  update_gui()

func remove_action(n):
  action_nodes.erase(n)
  update_gui()

func can_perform() -> bool:
  var action_node = action_node()

  if not action_node or not action_node.has_method("can_perform"):
    return false

  return action_node.can_perform()

func perform():
  var action_node = action_node()

  if not action_node or not action_node.has_method("perform") or not can_perform():
    return

  return action_node.perform()


func update_gui():
  action_label.text = get_display()
