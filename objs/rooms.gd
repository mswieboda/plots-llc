extends StaticBody3D

const NUM_MODULES = 25

var module_scene = preload("res://objs/module.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
  var shape: BoxShape3D = $collision_floor.shape
  var room_size = shape.size.x

  var size = NUM_MODULES / room_size + 1

  for row in range(size):
    for col in range(size):
      var module: Node3D = module_scene.instantiate()
      module.position = Vector3(row * size - size, 0, col * size - size)
      $modules.add_child(module)
