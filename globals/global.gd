extends Node

const RAW_MATERIALS = ['seeds', 'liquid oxygen', 'solar disk']
const PLOTS = ['farm', 'drill', 'oxygen pump', 'solar panel']
const RESOURCES = ['food', 'oxygen', 'metal']

var is_power_out = false


func remove_nodes(parent: Node3D):
  for node in parent.get_children():
    parent.remove_child(node)
    node.queue_free()


func create_plot_node(plot):
  var node = preload("res://objs/plots/default.tscn")

  if plot == "farm":
    node = preload("res://assets/models/plots/farm/plant.gltf")
  elif plot == "drill":
    node = preload("res://assets/models/plots/drill/drill.gltf")
  elif plot == "solar panel":
    node = preload("res://assets/models/plots/solar_panel/solar_module_joined.gltf")
  elif plot == "oxygen pump":
    node = preload("res://assets/models/plots/o2/o2.gltf")

  return node.instantiate() if node else null


func create_carry_plot_node(plot):
  var node = null

  if plot == "farm":
    node = preload("res://assets/models/plots/farm/plant.gltf")
  elif plot == "drill":
    node = preload("res://assets/models/plots/drill/drill.gltf")
  elif plot == "solar panel":
    node = preload("res://assets/models/plots/solar_panel/solar_module_joined.gltf")
  elif plot == "oxygen pump":
    node = preload("res://assets/models/plots/o2/o2.gltf")

  return node.instantiate() if node else null

func create_resource_node(resource):
  var node = null

  if resource == "food":
    node = preload("res://objs/resources/food.tscn")
  elif resource == "oxygen":
    node = preload("res://objs/resources/oxygen.tscn")
  elif resource == "metal":
    node = preload("res://objs/resources/metal.tscn")

  return node.instantiate() if node else null


func create_raw_material_node(raw_material):
  var node = null

  if raw_material == "seeds":
    node = preload("res://objs/raw_materials/seeds.tscn")
  elif raw_material == "liquid oxygen":
    node = preload("res://objs/raw_materials/liquid_oxygen.tscn")
  elif raw_material == "solar disk":
    node = preload("res://objs/raw_materials/solar_disk.tscn")

  return node.instantiate() if node else null
