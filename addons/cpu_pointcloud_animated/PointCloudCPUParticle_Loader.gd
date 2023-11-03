@tool
extends Node

class_name PointCloudCPUParticleLoader


var thread := Thread.new()
var thread_timer : float 
var xyz_frame_list : PackedStringArray




@export_category("Import")
@export var imported : bool = false : set = set_imported
func set_imported(value:bool)->void:
	if thread.is_started() or imported:
		call_deferred("_exit_tree")
		imported = value
		return
	else:
		if file_extension == ".ply" and value == true:
			thread.start(ply_to_2Darray)
			print("loading ply")
		elif frame_first == 0 and frame_last == 0:
			imported = false
			"no xyz frames to import"
			return
		elif value == true:
			imported = value
			thread.start(xyz_to_2Darray)
			print(thread.is_started())
		else:
			if  positions.size()>0 or  colors.size()>0:
				print("Clearing position and/or color data first")
				positions = []
				colors = []
				imported = value
			else:
				imported = value
var save_path : String

@export_global_dir var load_dir : String
@export_enum(".xyz",".ply") var file_extension : String = ".xyz"

@export var frame_first : int
@export var frame_last : int
@export var frame_count : int = 0 : set = set_frame_count
func set_frame_count(v:int) ->void:
	frame_count = v

@export var most_points : int = 0 : set = set_most_points
func set_most_points(v:int)->void:
	most_points =v
@export var least_points : int = 0 : set = set_least_points
func set_least_points(v:int)->void:
	least_points = v

@export_category("data")
@export var positions : Array : set = set_positions
func set_positions(value:Array)->void:
	positions = value
	
@export var normals : Array : set = set_normals
func set_normals(value:Array)->void:
	normals = value
	
@export var colors : Array : set = set_colors
func set_colors(value:Array)->void:
	colors = value
	

func xyz_to_2Darray()->void:
	xyz_frame_list = get_xyz_file_paths(load_dir)

	xyz_frame_list.size()
	set_frame_count(xyz_frame_list.size())

	print("frames to import: ", frame_count)
	create_arrays_from_xyz_fileList()

	thread.call_deferred("wait_to_finish")

func ply_to_2Darray()->void:
	var position_data : Array = []
	var normal_data : Array = []
	var color_data : Array = []
	#get file & update points
	var file := FileAccess.open(load_dir, FileAccess.READ)
	var h1 := file.get_csv_line("\n")[0]

	var h2 :=  file.get_csv_line("\n")[0]

	var h3 :=  file.get_csv_line("\n")[0]

	h3.trim_prefix("element_vertex ")
	var v = int(h3)

	for h in 12:
		var hx :=  file.get_csv_line("\n")[0]

	
	var p : PackedVector3Array = []
	var c : PackedColorArray = []
	var n : PackedVector3Array = []

#	#process the file
	for i in v :
		var xyzrgb : PackedStringArray = file.get_csv_line(" ")
		var xyz := Vector3(float(xyzrgb[0]),float(xyzrgb[1]),float(xyzrgb[2]))
		var nxyz := Vector3(float(xyzrgb[3]),float(xyzrgb[4]),float(xyzrgb[5]))
		var rgb := Color(float(xyzrgb[6])/255,float(xyzrgb[7])/255,float(xyzrgb[8])/255)
		
#
		p.append(xyz)
		n.append(nxyz)
		c.append(rgb)
		if i%100000 == 0:
			print("loaded ", i, "/", v, ": ", xyz, nxyz, rgb)
	position_data.append(p)
	normal_data.append(n)
	color_data.append(c)
#
	print(" frames completed." )
	
#
	set_positions(position_data)
	set_normals(normal_data)
	set_colors(color_data)
	thread.call_deferred("wait_to_finish")


func get_xyz_file_paths(path:String)->PackedStringArray:
	var files : PackedStringArray = []
	var dir := DirAccess.open(path)
	var frame_num := frame_first
	
	dir.list_dir_begin()
	
	while true:
		var file : String = dir.get_next()
		
		if file == "" or frame_num > frame_last:
			break
		elif not file.begins_with("."):
			if file.ends_with(str(frame_num)+file_extension):
				files.append(file)
				frame_num += 1

	dir.list_dir_end()
	return files
	
func create_arrays_from_xyz_fileList()->void:

	var position_data : Array = []
	var color_data : Array = []

	
	for f in frame_count:
		#get file & update points
		var file := FileAccess.open(load_dir +"/" +  xyz_frame_list[f], FileAccess.READ)
		var num_of_points : int = int(file.get_csv_line(" ")[0])
		if num_of_points> most_points:
			most_points = num_of_points
		if least_points == 0:
			least_points = num_of_points
		elif num_of_points < least_points:
			least_points = num_of_points

		var p : PackedVector3Array = []
		var c : PackedColorArray = []

		for i in num_of_points + 1:

			if i == 0:
				pass
			else:
				var xyzrgb : PackedStringArray = file.get_csv_line(" ")

				var rgb := Color(float(xyzrgb[3])/255,float(xyzrgb[4])/255,float(xyzrgb[5])/255)
				var xyz := Vector3(float(xyzrgb[0]),float(xyzrgb[1]),float(xyzrgb[2]))

				p.append(xyz)
				c.append(rgb)

		position_data.append(p)
		color_data.append(c)
		print(f+1, "/", frame_count, " frames completed." )

	set_positions(position_data)
	set_colors(color_data)


func _ready() -> void:
	pass
		

func _process(delta: float) -> void:
	if thread.is_started() or thread.is_alive():

		thread_timer += delta
	elif thread_timer != 0:
		print("thread completed after: ", thread_timer, " seconds")
		thread_timer = 0.0
	else:
		thread_timer = 0.0

		

	
func _exit_tree() -> void:

	if thread.is_started():
		thread.wait_to_finish()
#
func save_data()->void:

	var file := FileAccess.open(save_path, FileAccess.WRITE)
	print(save_path)
	file.store_var(positions)
	file.store_var(colors)
	file.store_var(frame_count)
	file.store_var(most_points)
	file.store_var(least_points)

	pass
