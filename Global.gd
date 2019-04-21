extends Node

var font = preload("res://default_font.tres")

var map

enum {TILE_WALKABLE, TILE_BLOCKED, TILE_FREE, TILE_GOAL}
enum {BLOCK_MOVING, BLOCK_STOPPED}
enum {CHAR_WAITING, CHAR_SEARCHING}

var BLOCK_TILE_PER_SECOND = 0.1
var GRAVITY_TILE_PER_SECOND = 0.5

export var BLOCK_HEIGHT:int = 3
export var BLOCK_WIDTH:int = 3

onready var BLOCK_L = [
	[Global.TILE_BLOCKED, Global.TILE_WALKABLE, Global.TILE_BLOCKED],
	[Global.TILE_BLOCKED, Global.TILE_WALKABLE, Global.TILE_WALKABLE],
	[Global.TILE_BLOCKED, Global.TILE_BLOCKED, Global.TILE_BLOCKED],
]

onready var BLOCK_X = [
	[Global.TILE_BLOCKED, Global.TILE_WALKABLE, Global.TILE_BLOCKED],
	[Global.TILE_WALKABLE, Global.TILE_WALKABLE, Global.TILE_WALKABLE],
	[Global.TILE_BLOCKED, Global.TILE_WALKABLE, Global.TILE_BLOCKED],
]

onready var BLOCK_T = [
	[Global.TILE_BLOCKED, Global.TILE_WALKABLE, Global.TILE_BLOCKED],
	[Global.TILE_WALKABLE, Global.TILE_WALKABLE, Global.TILE_WALKABLE],
	[Global.TILE_BLOCKED, Global.TILE_BLOCKED, Global.TILE_BLOCKED],
]

onready var BLOCK_I = [
	[Global.TILE_BLOCKED, Global.TILE_BLOCKED, Global.TILE_BLOCKED],
	[Global.TILE_WALKABLE, Global.TILE_WALKABLE, Global.TILE_WALKABLE],
	[Global.TILE_BLOCKED, Global.TILE_BLOCKED, Global.TILE_BLOCKED],
]

onready var BLOCK_TYPES = [BLOCK_L, BLOCK_X, BLOCK_T, BLOCK_I]

var BLOCK_SCENE = preload("res://block.tscn")

func _ready():
	add_to_group("needs_block_stopped")
	
func _input(event):
	if Input.is_action_just_pressed("reload_scene"):
		get_tree().reload_current_scene()

func block_stopped(block):
	var block_width_px = BLOCK_WIDTH * map.TILE_SIZE
	var x = ( randi() % map.MAP_WIDTH )  * map.TILE_SIZE
	x = clamp(x, block_width_px, map.MAP_WIDTH * map.TILE_SIZE - block_width_px)
	var y = BLOCK_HEIGHT * map.TILE_SIZE
	var new_block = BLOCK_SCENE.instance()
	new_block.position = Vector2(x,y)
	get_node("/root/world/blocks").add_child(new_block)
