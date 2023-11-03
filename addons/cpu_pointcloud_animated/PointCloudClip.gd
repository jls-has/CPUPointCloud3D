@tool
extends CPUParticles3D
#Must be a parent of PointCloudCPUParticleLoader

class_name PointCloudCPUParticleClip
var frame_timer : float = 0.0

var xyz_frame_list : PackedStringArray
var private_frame_count : int

var timer : Timer
var init := false;
var forwards := true;

signal finished
signal frame(f:int)


@export_category("Import")
@export var add_to_existing : bool = false
@export var imported : bool = false : set = set_imported
func set_imported(value:bool)->void:
	if not init:
		return
	if imported:
		print("Clearing position and/or color data first")
		positions = []
		colors = []
		imported = value
		return
	else:
		if value == true:
			current_frame = 0
			imported = value
			
			if get_child(0).get_name() == "PointCloudCPUParticleLoader":
				if  positions.size()>0 or  colors.size()>0:
					if not add_to_existing:
						print("Clearing position and/or color data first")
						positions = []
						colors = []
				imported = value
				load_from_child()
			else: 
				imported = false
				print("add a child:  PointCloudCPUParticleLoader")
			#thread.start(load_file)
			
		else:
			set_playing(false)
##			
			imported = value


@export_category("data")
@export var most_points : int
@export var least_points : int
@export var positions : Array  = [] : set = set_positions
func set_positions(value:Array)->void:
	positions = value
	

@export var colors : Array = [] : set = set_colors
func set_colors(value:Array)->void:
	colors = value

@export var frame_count : int

@export_category("Player")
@export var current_frame = 0
var player_camera : Camera3D 

## This sets the amount every frame, making for a more jittery animation
@export var refresh_every_frame := false

## This divides the number of points by the resolution, allowing for smoother playback.  A higher number is less resolved.
@export var resolution : int = 2
@export var frames_alive : int = 2 : set = set_frames_alive
func set_frames_alive(v: int)->void:
	frames_alive = v
	set_lifetime(frames_alive/float(fps))
@export var autostart : bool = false

@export var playing : bool = false : set = set_playing
func set_playing(value: bool)->void:
	
	playing = value
	if playing:
		set_emitting(true)
		print(get_name(), "emitting: ", emitting, "playing ", playing, global_position)


@export var fps := 30 : set = set_fps
func set_fps(value:int)->void:
	fps = value
	#timer.set_wait_time(1.0/float(fps))
	set_fixed_fps(fps)
	set_lifetime(frames_alive/float(fps))
	
enum looping {LOOP, PINGPONG, FREEZE}
@export var loop : looping 

@export var mesh_point_size := 2.0 : set = set_mps
func set_mps(v:float)->void:
	mesh_point_size = v
	mesh.surface_get_material(0).set_flag(BaseMaterial3D.FLAG_USE_POINT_SIZE, true)
	mesh.surface_get_material(0).set_point_size(v)

@export var trim_end :int= 0: set = set_trim_end
func set_trim_end (v:int)->void:
	trim_end = v
	if v == 0:
		return
	if positions.size() > v:
		positions.resize(v)
		colors.resize(v)
	else:
		trim_end = 0
	frame_count = positions.size()
		
	
@export var trim_begin :int= 0: set = set_trim_begin
func set_trim_begin (v:int)->void:
	trim_end = v
	if v == 0:
		return
	if v< positions.size():
		for i in v:
			positions.remove_at(0)
			colors.remove_at(0)
	frame_count = positions.size()
@export var static_current := false : set = set_static_current
func set_static_current(v:bool)->void:
	var p_frame :PackedVector3Array =positions[current_frame]
	var c_frame :PackedColorArray= colors[current_frame]
	positions = []
	colors = []
	positions.append(p_frame)
	colors.append(c_frame)
	set_emission_points(positions[current_frame])
	set_emission_colors(colors[current_frame])

var dbg_string := "\n"
func load_from_child()->void:
	var loader = get_child(0)
	if add_to_existing:
		colors.append_array(loader.colors)
		positions.append_array(loader.positions)
		frame_count += loader.frame_count
		most_points = max(most_points, loader.most_points)
		least_points = min(least_points, loader.least_points)
	else:
		colors = loader.colors
		positions = loader.positions
		frame_count = loader.frame_count
		most_points = loader.most_points
		least_points = loader.least_points
	

func _ready() -> void:
	imported = false
	current_frame = 0
	set_emission_points([])
	set_emission_colors([])

		

func _process(delta: float) -> void:
	
	if not init:
		if autostart:
			set_playing(true)
		init = true
		print(get_name(), " initialized")
	
	
	if playing:
		frame_timer += delta
		if frame_timer >= 1.0/float(fps):
			play_animation()
			frame_timer -=1.0/float(fps)
			
	if player_camera and emitting:
		var mps : float = lerp(10.0, 2.0, position.distance_to(player_camera.position)/5)
		set_mps(mps)

		
		
func play_animation()->void:
	if refresh_every_frame:
		set_amount(positions[current_frame].size()/resolution)
	set_emission_points(positions[current_frame])
	set_emission_colors(colors[current_frame])

	if loop == looping.LOOP:
		current_frame +=1
		if current_frame >= frame_count:
			current_frame = 0;
	elif loop == looping.PINGPONG:
		if forwards:
			current_frame +=1
		else:
			current_frame -= 1
		if current_frame >= frame_count-1 or current_frame <=0:
			forwards = !forwards
	elif loop == looping.FREEZE:
		current_frame +=1
		if current_frame >= frame_count:
			current_frame = frame_count-1
			emit_signal("finished")
	else:
		playing = false
	emit_signal("frame", current_frame)
func _exit_tree() -> void:
	set_playing(false)


func _on_stop_playing_if_not_visible_screen_exited() -> void:
	set_playing(false)
	print(frame_count)


func _on_stop_playing_if_not_visible_screen_entered() -> void:
	set_playing(true)


func make_alive() -> void:
	#visible=true
	current_frame = 0
	set_emission_points([])
	set_emission_colors([])
	set_playing(true)



func make_asleep() -> void:

	set_emitting(false)
	await get_tree().create_timer(get_lifetime()).timeout
	queue_free()
	
	
