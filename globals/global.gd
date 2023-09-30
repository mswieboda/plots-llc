extends Node


func remove_nodes(parent: Node3D):
  for node in parent.get_children():
    parent.remove_child(node)
    node.queue_free()
