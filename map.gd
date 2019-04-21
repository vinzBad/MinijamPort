extends Node2D
tool
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var MAP_HEIGHT: int = 15
export var MAP_WIDTH: int = 30
export var TILE_SIZE: int = 16

var TILE_SCENE = preload("res://tile.tscn")

var nav = AStar.new()

var tiles = []
var goals = []

onready var camera = get_node("/root/world/camera") as Camera2D

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.editor_hint:
		return
	Global.map = self
	camera.position.x = MAP_WIDTH / 2 * TILE_SIZE + TILE_SIZE / 2
	camera.position.y = MAP_HEIGHT  * TILE_SIZE - get_viewport_rect().size.y / 2
	var nav_id_counter = 1
	for x in range(MAP_WIDTH):
		tiles.append([])
		for y in range(MAP_HEIGHT):
			var tile = TILE_SCENE.instance()			
			tiles[x].append(tile)
			add_child(tile)
			tile.position.x = x  * TILE_SIZE 
			tile.position.y = y * TILE_SIZE
			tile.xIndex = x
			tile.yIndex = y
			tile.nav_id = nav_id_counter
			tile.register_nav(self.nav)
			nav_id_counter += 1
	for x in range(MAP_WIDTH):
		tiles[x][MAP_HEIGHT-1].set_state(Global.TILE_WALKABLE)
		tiles[x][MAP_HEIGHT-2].set_state(Global.TILE_WALKABLE)
		tiles[x][0].set_state(Global.TILE_GOAL)

func is_tile_index_in_bounds(x:int, y:int):
	return x >= 0 and x < MAP_WIDTH and y >= 0 and y < MAP_HEIGHT

func tile_at_global_position(global_position:Vector2):
	var local_position = to_local(global_position)
	var x = int(local_position.x / TILE_SIZE)
	var y = int(local_position.y / TILE_SIZE)
	if is_tile_index_in_bounds(x,y):
		return tiles[x][y]

func tile_to_global_position(tile):
	return to_global(Vector2(tile.xIndex * TILE_SIZE, tile.yIndex * TILE_SIZE))

func neighbor_at_offset(tile, x_offset, y_offset):
	var new_x = tile.xIndex + x_offset
	var new_y = tile.yIndex + y_offset
	if is_tile_index_in_bounds(new_x, new_y):
		return tiles[new_x][new_y]
	return null
	
func get_tile_neighbors(tile):
	var neighbors = []
	if tile == null:
		return neighbors
	for offset in  [[-1,0], [1,0], [0,-1], [0,1]]:
		var x = tile.xIndex + offset[0]
		var y = tile.yIndex + offset[1]
		if is_tile_index_in_bounds(x,y):
			neighbors.append(tiles[x][y])
	return neighbors
		
	
var prev_tile

#func _process(delta):
#	self.update()
#	var tile = tile_at_global_position( get_global_mouse_position())
#	if tile:
#		if prev_tile:
#			prev_tile.state = Global.TILE_FREE
#			prev_tile.update()
#
#		tile.state = Global.TILE_BLOCKED
#		tile.update()
#		prev_tile = tile
		
func indices_to_world_pos(x,y):
	return Vector2(x * TILE_SIZE + TILE_SIZE/2, y * TILE_SIZE + TILE_SIZE/2)
	
		
				
			

func _draw():
	if Engine.editor_hint:
		for x in range(1, MAP_WIDTH):
			draw_line(Vector2(x*TILE_SIZE, 0), Vector2(x*TILE_SIZE, TILE_SIZE * MAP_HEIGHT), Color.wheat, 2)
		for y in range(1, MAP_HEIGHT):
			draw_line(Vector2(0, y*TILE_SIZE), Vector2(TILE_SIZE * MAP_WIDTH, y*TILE_SIZE), Color.wheat, 2)
#func _input(event):
#	if event.is_action_released("left_click") and Input.is_action_just_released("left_click"):
#		var tile = tile_at_global_position( get_global_mouse_position())
#		if tile:
#			tile.inc_state()
#
		
			