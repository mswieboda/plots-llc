extends Node

var actions = []


func action():
  if actions.is_empty():
    return null

  var actions_dup = actions.duplicate()
  actions_dup.reverse()

  for a in actions_dup:
    if a and a["node"].has_method("can_perform") and a["node"].can_perform():
      return a

  return actions[-1]


func action_node():
  if not action():
    return null

  return action()["node"]


func is_action_node(n, input = "action"):
  var node = action_node()

  return node and node.name == n.name


func get_display() -> String:
  var a = action()

  if not a:
    return " "

  var node = a["node"]

  if can_perform():
    if node and node.has_method("get_action_name"):
      return "press [" + a["display"] + "] to " + node.get_action_name()

  if node and node.has_method("get_action_info"):
    return node.get_action_info()

  return " "


func add_action(n, input = "action", display = "E"):
  actions.append({ "node": n, "input": input, "display": display })
  update_gui()

func add_action_least_priority(n, input = "action", display = "E"):
  actions.push_front({ "node": n, "input": input, "display": display })
  update_gui()

func remove_action(n, input = "action"):
  if actions.is_empty():
    return

  var index = -1

  for i in actions.size():
    if actions[i]["node"] == n and actions[i]["input"] == input:
      index = i

  if index == -1:
    return

  actions.remove_at(index)
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
  var action_label = get_node('/root/main/player/action_gui/margin/action_label')

  if action_label:
    action_label.text = get_display()
