extends Node2D

func _ready():
	pass
	
func _process(delta):
	self.update()

func _draw():
	var map = Global.map
	var nav = Global.map.nav
	for nav_id in nav.get_points():
		var pos = nav.get_point_position(nav_id)
		for conn_id in nav.get_point_connections(nav_id):
			var conn_position = nav.get_point_position(conn_id)
			var start_pos = map.indices_to_world_pos(pos.x, pos.y)
			var end_pos = map.indices_to_world_pos(conn_position.x, conn_position.y)
			draw_line(
				start_pos,
				end_pos,
				Color.orange)