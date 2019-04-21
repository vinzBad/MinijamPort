extends Node2D
class_name Tile
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

static func sort_tiles_by_y(a,b):
	if a.yIndex < b.yIndex:
		return true
	return false

var xIndex : int
var yIndex: int
var nav_id: int
var nav:AStar

var state = Global.TILE_FREE
var old_state = Global.TILE_FREE

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.s

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func register_nav(nav:AStar):
	self.nav = nav
	self.nav.add_point(nav_id, Vector3(xIndex, yIndex,0))

func update_nav():
	# WHEN FREE or GOAL connect to walkable neighbors
	# WHEN WALKABLE connect to WALKABLE, GOAL and FREE neighbors
	var neighbors = Global.map.get_tile_neighbors(self)
	for neighbor in neighbors:
		if self.state in [Global.TILE_WALKABLE, Global.TILE_GOAL]:
			if neighbor.state in [Global.TILE_WALKABLE, Global.TILE_GOAL]:
				nav.connect_points(self.nav_id, neighbor.nav_id)
		if self.state in [Global.TILE_BLOCKED, Global.TILE_FREE]:
			for conn_id in Global.map.nav.get_point_connections(nav_id):
				Global.map.nav.disconnect_points(nav_id, conn_id)

func update_cache():
	if self.old_state != Global.TILE_GOAL and self.state == Global.TILE_GOAL:
		if not self in Global.map.goals:
			Global.map.goals.append(self)

func inc_state():
	self.set_state((self.state +1)  % 4)

func set_state(new_state):
	
	if self.state != new_state:
		self.old_state = self.state
		self.state = new_state
		self.update()
		self.update_nav()


func _draw():
	var rect_size = Vector2(Global.map.TILE_SIZE, Global.map.TILE_SIZE)
	var state_text = "NONE"
	if (state == Global.TILE_FREE):
		draw_rect(Rect2(Vector2.ZERO, rect_size ), Color.blue);
		state_text = "FREE"
	elif (state == Global.TILE_BLOCKED):
		draw_rect(Rect2(Vector2.ZERO, rect_size ), Color.red);
		state_text = "BLOCKED"
	elif (state == Global.TILE_WALKABLE):
		draw_rect(Rect2(Vector2.ZERO, rect_size ), Color.green);
		state_text = "WALKABLE"
	elif (state == Global.TILE_GOAL):
		draw_rect(Rect2(Vector2.ZERO, rect_size ), Color.yellow);
		state_text = "GOAL"
	
	# draw_rect(Rect2(Vector2.ZERO, rect_size), Color.red, false);
	# draw_string(Global.font,  Vector2(0,16),  state_text, Color.black)

		
