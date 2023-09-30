extends Camera3D

@onready var player = get_parent().get_node('player')
var distance = 0

func _ready():
  distance = global_position.z - player.global_position.z


func _process(_delta):
  global_position.z = player.global_position.z + distance
  global_position.x = player.global_position.x
