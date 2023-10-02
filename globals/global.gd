extends Node

const RAW_MATERIALS = ["seeds", "liquid oxygen"]
const PLOTS = ['farm', 'drill', 'oxygen pump', 'solar panel']
const RESOURCES = ['food', 'oxygen', 'metal', 'solar panel']


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
  elif resource == "solar panel":
    node = preload("res://objs/resources/solar_panel.tscn")

  return node.instantiate() if node else null


func create_raw_material_node(raw_material):
  var node = null

  if raw_material == "seeds":
    node = preload("res://objs/raw_materials/seeds.tscn")
  if raw_material == "liquid oxygen":
    node = preload("res://objs/raw_materials/liquid_oxygen.tscn")

  return node.instantiate() if node else null
