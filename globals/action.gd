extends Node

var action_nodes = []

@onready var action_label = get_node('/root/main/player/action_gui/margin/action_label')

func action_node():
  if action_nodes.is_empty():
    return null

  var nodes = action_nodes.duplicate()
  nodes.reverse()

  for n in nodes:
    if n and n.has_method("can_perform") and n.can_perform():
      return n

  return action_nodes[-1]


func is_action_node(n):
  var node = action_node()

  return node and node.name == n.name


func get_display() -> String:
  var node = action_node()

  if can_perform():
    if node and node.has_method("get_action_name"):
      return "press [E] to " + node.get_action_name()

  if node and node.has_method("get_action_info"):
    return node.get_action_info()

  return " "


func add_action(n):
  action_nodes.append(n)
  update_gui()

func add_action_least_priority(n):
  action_nodes.push_front(n)
  update_gui()

func remove_action(n):
  action_nodes.erase(n)
  update_gui()

func can_perform() -> bool:
  var node = action_node()

  if not node or not node.has_method("can_perform"):
    return false

  return node.can_perform()

func perform():
  var node = action_node()

  if not node or not node.has_method("perform") or not can_perform():
    return

  node.perform()
  node.update_changes()


func update_changes():
  var node = action_node()

  if node:
    node.update_changes()

  update_gui()


func update_gui():
  action_label.text = get_display()
