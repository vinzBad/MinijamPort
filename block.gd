extends Node2D


var state = Global.BLOCK_MOVING

var tiles = []
var new_tiles = []

func _ready():
	for x in range(Global.BLOCK_WIDTH):
		new_tiles.append([])	
		for y in range(Global.BLOCK_HEIGHT):
			new_tiles[x].append(-1)
	tiles = Global.BLOCK_TYPES[randi() % len(Global.BLOCK_TYPES)]
	$gravity_timer.wait_time = Global.GRAVITY_TILE_PER_SECOND
#warning-ignore:return_value_discarded
	$gravity_timer.connect("timeout", self, "move_down")
	$gravity_timer.start()
	$move_timer.wait_time = Global.BLOCK_TILE_PER_SECOND
	
	
	position.x = clamp(
		position.x, 
		Global.BLOCK_WIDTH / 2 * Global.map.TILE_SIZE, 
		Global.map.TILE_SIZE * Global.map.MAP_WIDTH - Global.BLOCK_WIDTH / 2 * Global.map.TILE_SIZE)
	
	position.x = int(position.x / (Global.map.TILE_SIZE * 3)) * (Global.map.TILE_SIZE * 3)# + Global.map.TILE_SIZE / 2
	position.y = int(position.y / (Global.map.TILE_SIZE * 3)) * (Global.map.TILE_SIZE * 3)# + Global.map.TILE_SIZE / 2

	

func tile_at_indices(x:int, y:int):
	return Global.map.tile_at_global_position(to_global(indices_to_local_pos(x, y)))

#warning-ignore:unused_argument
func _process(delta):
	if state == Global.BLOCK_MOVING:
		if Input.is_action_pressed("ui_left") and $move_timer.is_stopped():
			self.position.x -= Global.map.TILE_SIZE * 3
			if is_sides_colliding():
				self.position.x += Global.map.TILE_SIZE * 3
			$move_timer.start()
		if Input.is_action_pressed("ui_right") and $move_timer.is_stopped():
			self.position.x += Global.map.TILE_SIZE * 3
			if is_sides_colliding():
				self.position.x -= Global.map.TILE_SIZE * 3
			$move_timer.start()
		if Input.is_action_pressed("ui_down") and $move_timer.is_stopped():
			move_down()
			$move_timer.start()
			
#warning-ignore:unused_argument
func _input(event):
	if state == Global.BLOCK_MOVING:
		if Input.is_action_just_pressed("ui_page_down"):
			rotate_tiles(90)
			update()
#			rotate(deg2rad(90))
		if Input.is_action_just_pressed("ui_page_up"):
			rotate_tiles(-90)
			#rotate(deg2rad(-90))
			update()



func move_down():
	if state == Global.BLOCK_MOVING:
		self.position.y += Global.map.TILE_SIZE
		if is_down_colliding():
			state = Global.BLOCK_STOPPED
			self.position.y -= Global.map.TILE_SIZE
			apply_block_to_map()
			get_tree().call_group("needs_block_stopped", "block_stopped", self)
			
func indices_to_pos(x:int, y:int):
	return Vector2(
		x * Global.map.TILE_SIZE,
		y * Global.map.TILE_SIZE)

func map_tile_at_indices(x:int, y:int):
	return Global.map.tile_at_global_position(indices_to_global_pos(x,y))

func indices_to_global_pos(x:int, y:int):
	return to_global(indices_to_local_pos(x,y))

func indices_to_local_pos(x:int, y:int, rotate_indices=false):
	if rotate_indices:
		var rotated_indices = get_rotated_indices(x,y)
#		x = int(rotated_indices.x)
#		y = int(rotated_indices.y)
	return Vector2(
		x * Global.map.TILE_SIZE, #- (Global.BLOCK_WIDTH * 0.5) * Global.map.TILE_SIZE,
		y * Global.map.TILE_SIZE)#- (Global.BLOCK_HEIGHT * 0.5) * Global.map.TILE_SIZE)
		

func apply_block_to_map():
	for x in range(Global.BLOCK_HEIGHT):
		for y in range(Global.BLOCK_HEIGHT):
			#var rotated_indices = get_rotated_indices(x,y)
			#x = int(rotated_indices.x)
			#y = int(rotated_indices.y)
			var tile_state = tiles[x][y]
			var tile_local_pos = indices_to_local_pos(x,y)
			var tile_global_pos = self.to_global(tile_local_pos) + Vector2(Global.map.TILE_SIZE  / 2, Global.map.TILE_SIZE  / 2)
			var tile = Global.map.tile_at_global_position(tile_global_pos)
			if tile:
				tile.set_state(tile_state)
			else:
				print("BLOCK OUT OF BOUNDS")
			

func rotate_tiles(degrees):
	var index_offset = Vector2(int(Global.BLOCK_WIDTH / 2), int(Global.BLOCK_HEIGHT/ 2))
	
#	print("rotate ", degrees)
	
	
	for x in range(Global.BLOCK_WIDTH):		
		for y in range(Global.BLOCK_HEIGHT):
			var state = tiles[x][y] 
			var indices = Vector2(x,y)
#			print("indices", indices)
			
			var offset_indices = indices - index_offset
#			print("with offset", offset_indices)
			var rotated_offset_indices = offset_indices.rotated(deg2rad(degrees)) 
#			print("after rotation", rotated_offset_indices)
			var rotated_indices = rotated_offset_indices + index_offset
#			print(indices, "=>", rotated_indices, " ~ ", int(round(rotated_indices.x)), ", ", int(round(rotated_indices.y)), ": ", state)
#			print("pre: ", new_tiles)
			
			new_tiles[int(round(rotated_indices.x))][int(round(rotated_indices.y))] = state
#			print("after: ", new_tiles)
	
	for x in range(Global.BLOCK_WIDTH):
		for y in range(Global.BLOCK_HEIGHT):			
			tiles[x][y] = new_tiles[x][y]
#	print("finished")
	

func get_rotated_indices(x,y):
	return Vector2(x,y).rotated(self.rotation)
	 
	
func is_down_colliding():
	for x in range(Global.BLOCK_WIDTH):
		var lower_tile_local_pos = indices_to_local_pos(x,Global.BLOCK_HEIGHT -1, true)
		var tile = Global.map.tile_at_global_position(to_global(lower_tile_local_pos))
		if tile:
			if tile.state == Global.TILE_BLOCKED:
				return true
		else:
			return true
	return false
	
func is_sides_colliding():
	for y in range(Global.BLOCK_HEIGHT):
		var left_tile_local_pos = indices_to_local_pos(0, y)
		var tile = Global.map.tile_at_global_position(to_global(left_tile_local_pos))
		if tile:
			if tile.state == Global.TILE_BLOCKED:
				return true
		else:
			return true
			
		var right_tile_local_pos = indices_to_local_pos(Global.BLOCK_WIDTH - 1, y, true)
		tile = Global.map.tile_at_global_position(to_global(right_tile_local_pos))
		if tile:
			if tile.state == Global.TILE_BLOCKED:
				return true
		else:
			return true
	return false
	

func _draw():
#	draw_rect(Rect2(
#		indices_to_local_pos(0,0), 
#		Vector2(Global.map.TILE_SIZE * Global.BLOCK_WIDTH, Global.map.TILE_SIZE * Global.BLOCK_HEIGHT)),
#		Color.antiquewhite) 
	
	for x in range(Global.BLOCK_WIDTH):
		for y in range(Global.BLOCK_HEIGHT):
			var state = tiles[x][y]
			var local_pos = indices_to_local_pos(x,y)
			if (state == Global.TILE_BLOCKED):
				draw_rect(Rect2(
					Vector2(
						local_pos.x + Global.map.TILE_SIZE * 0.1,
						local_pos.y + Global.map.TILE_SIZE * 0.1),
					Vector2(Global.map.TILE_SIZE, Global.map.TILE_SIZE ) * 0.80),
					Color("71266E"))
			elif (state == Global.TILE_WALKABLE):
				draw_rect(Rect2(
					Vector2(
						local_pos.x + Global.map.TILE_SIZE * 0.1,
						local_pos.y + Global.map.TILE_SIZE * 0.1),
					Vector2(Global.map.TILE_SIZE, Global.map.TILE_SIZE ) * 0.80),
					Color("FEEC39"))
#	draw_circle(Vector2.ZERO, 5, Color.magenta)