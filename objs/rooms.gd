extends StaticBody3D

const NUM_MODULES = 25

var plot_scene = preload("res://objs/plot.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
  var shape: BoxShape3D = $collision_floor.shape
  var room_size = shape.size.x

  var size = NUM_MODULES / room_size + 1

  for row in range(size):
    for col in range(size):
      var plot: Node3D = plot_scene.instantiate()
      plot.position = Vector3(row * size - size, 0, col * size - size)
      $plots.add_child(plot)

  # room wall meshes to concrete
  for node in $mesh.get_children():
    if node.has_method("get_material_override") and node.name.begins_with("wall"):
      node.material_override = preload("res://assets/materials/concrete.tres")

  # living room wall meshes to concrete
  for node in $living_room/mesh.get_children():
    if node.has_method("get_material_override"):
      node.material_override = preload("res://assets/materials/concrete.tres")
