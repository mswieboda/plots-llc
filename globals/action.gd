extends Node

var node

func get_display() -> String:
  if not node or not node.has_method("get_action_name"):
    return " "

  return "Press [E] to " + node.get_action_name()

func set_node(n):
  node = n

func can_perform() -> bool:
  if not node or not node.has_method("can_perform"):
    return false

  return node.can_perform()

func perform():
  if not node or not node.has_method("perform") or not can_perform():
    return

  return node.perform()
