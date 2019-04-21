extends Node2D
class_name Character
export var CHARACTER_SIZE: int = 8

var state = Global.CHAR_WAITING
var is_moving_left = true

var highest_walkables = []
var path = []

func _ready():
	position.x = Global.map.TILE_SIZE * Global.map.MAP_WIDTH / 2 + Global.map.TILE_SIZE /2
	position.y = Global.map.TILE_SIZE * Global.map.MAP_HEIGHT  - Global.map.TILE_SIZE /2
	
	add_to_group("needs_block_stopped")

func get_current_tile():
	return Global.map.tile_at_global_position(to_global(Vector2.ZERO))

func get_current_neighbors():
	return Global.map.get_tile_neighbors(get_current_tile())

func get_next_tile_to_highest_walkable(current):
	if len(path) > 0:
		var next =  path.pop_front()
		if next.state == Global.TILE_WALKABLE:
			return next
		path.clear() # path has become blocked
	

	for i in range(len(highest_walkables)):
		var target = highest_walkables[i]
		var target_path = get_path_to_tile(target)
		if len(target_path) > 0:
			path = target_path
			return path.pop_front()

	return null

func get_next_tile():
	var current = get_current_tile()
	
	if len(highest_walkables) > 0:
		var next_tile = get_next_tile_to_highest_walkable(current)
		if next_tile != null:# and next_tile.state == Global.TILE_WALKABLE:
			return next_tile
	
	var upper_neighbor = Global.map.neighbor_at_offset(current, 0, -1)
	var left_neighbor = Global.map.neighbor_at_offset(current, -1, 0)
	var right_neighbor = Global.map.neighbor_at_offset(current, 1, 0)
	
	if upper_neighbor != null and upper_neighbor.state == Global.TILE_WALKABLE:
		return upper_neighbor
	
	if is_moving_left:
		if left_neighbor != null and left_neighbor.state == Global.TILE_WALKABLE:
			return left_neighbor
		else:
			is_moving_left = false
	
	if not is_moving_left:
		if right_neighbor != null and right_neighbor.state == Global.TILE_WALKABLE:
			return right_neighbor
		else: 
			if left_neighbor != null and left_neighbor.state == Global.TILE_WALKABLE:
				is_moving_left = true
				return left_neighbor 
			
	return null
	
		
#warning-ignore:unused_argument
func _process(delta):
	self.update()
	var tile = get_current_tile()
	var neighbors = get_current_neighbors()
	
	if state == Global.CHAR_SEARCHING and $move_timer.is_stopped(): 
		var next_tile = get_next_tile()

		if next_tile != null:
			$move_timer.start()
			var delta_pos = Vector2(next_tile.xIndex - tile.xIndex ,  next_tile.yIndex - tile.yIndex ) * Global.map.TILE_SIZE
			self.position += delta_pos
			




func block_stopped(block):
	# prune highest_walkables
	var removable_indices = []
	for i in range(len(highest_walkables)):
		var tile = highest_walkables[i]
		var remove_tile = true
		for neighbor in Global.map.get_tile_neighbors(tile):
			if neighbor != null and neighbor.state == Global.TILE_FREE:
				remove_tile = false
		if remove_tile:
			removable_indices.append(i)
	
	for i in removable_indices:
		highest_walkables.remove(i)
	
	# find new highest walkables
	for x in range(Global.BLOCK_WIDTH):
		for y in range(Global.BLOCK_HEIGHT):
			var tile = block.map_tile_at_indices(x,y)
			if tile != null and tile.state == Global.TILE_WALKABLE:
				var neighbors = Global.map.get_tile_neighbors(tile)
				for neighbor in neighbors:
					if neighbor != null and neighbor.state == Global.TILE_FREE:
						highest_walkables.append(tile)
						break
	
	# sort by lowest y
	highest_walkables.sort_custom(Tile, "sort_tiles_by_y")
	
			
	if state == Global.CHAR_WAITING:
		state = Global.CHAR_SEARCHING

func get_path_to_tile(target):
	var path = []
	var current = get_current_tile()
	var path_positions = Global.map.nav.get_point_path(current.nav_id, target.nav_id)
	if len(path_positions) > 0:
		for pos in path_positions:
			path.push_back(Global.map.tiles[int(round(pos.x))][int(round(pos.y))])
	return path

func _draw():
	draw_circle(Vector2.ZERO, CHARACTER_SIZE, Color("B0002F"))
#	for tile in highest_walkables:
#		var tile_local_pos = to_local(tile.to_global(Vector2.ONE * Global.map.TILE_SIZE / 2))
#		draw_circle(tile_local_pos, CHARACTER_SIZE * 0.8, Color.goldenrod)
#	for wlk in highest_walkables:
#		for tile in get_path_to_tile(wlk):
#			var tile_local_pos = to_local(tile.to_global(Vector2.ONE * Global.map.TILE_SIZE / 2))
#			draw_circle(tile_local_pos, CHARACTER_SIZE * 0.6, Color.pink)