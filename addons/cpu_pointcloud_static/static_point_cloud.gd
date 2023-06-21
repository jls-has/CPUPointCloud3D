@tool
extends CPUParticles3D

var thread := Thread.new()
var thread_timer : float = 0.0
var vertices : int = 0
var positions : Array 
var colors : Array 
var normals : Array 

@export_category("Static Point Cloud")
@export var source_mesh : Mesh : set = import_mesh
func import_mesh(v:Mesh) ->void:
	source_mesh = v
	if thread.is_started():
		print("thread is already started")
		return
	elif source_mesh:
		positions = []
		colors = []
		normals = []
		thread.start(load_from_mesh)
		print("Thread is started: ", thread.is_started())
	else:
		set_emitting(false)
		

@export var mesh_point_size := 2.0 : set = set_mps
func set_mps(v:float)->void:
	mesh_point_size = v
	if not mesh:
		add_point_mesh_to_draw()
	mesh.surface_get_material(0).set_point_size(v)

@export var max_points : int= 10000
 



func _ready() -> void:
	set_emitting(false)
	set_emission_shape(CPUParticles3D.EMISSION_SHAPE_DIRECTED_POINTS)
	add_point_mesh_to_draw()
	
	
func add_point_mesh_to_draw()->void:
	var m: Mesh = PointMesh.new()
	var mat := StandardMaterial3D.new()
	mat.set_flag(BaseMaterial3D.FLAG_USE_POINT_SIZE, true)
	mat.set_flag(BaseMaterial3D.FLAG_ALBEDO_FROM_VERTEX_COLOR, true)
	mat.set_point_size(mesh_point_size)
	set_mesh(m)
	mesh.surface_set_material(0, mat)
	
func load_from_mesh()->void:
	var mdt := MeshDataTool.new()
	mdt.create_from_surface(source_mesh, 0)
	vertices = mdt.get_vertex_count()
	print(source_mesh, " has ", mdt.get_vertex_count(), " vertices.")
	positions = []
	normals =[]
	colors = []
	var shuffled_verts : Array = []
	for v in vertices:
		shuffled_verts.append(v)
	shuffled_verts.shuffle()
	for v in vertices:
		positions.append(mdt.get_vertex(shuffled_verts[v]))
		colors.append(mdt.get_vertex_color(shuffled_verts[v]))
		normals.append(mdt.get_vertex_normal(shuffled_verts[v]))
		if v % 10000 == 0:
			print(v, "/", vertices)
	set_emission_points(positions)
	set_emission_colors(colors)
	set_emission_normals(normals)
	set_emitting(true)
	set_amount(min(max_points,vertices))
	set_gravity(Vector3.ZERO)
	thread.call_deferred("wait_to_finish")

func _process(delta: float) -> void:
	if thread.is_started() or thread.is_alive():
		thread_timer += delta
	elif thread_timer != 0:
		print("thread completed after: ", thread_timer, " seconds")
		thread_timer = 0.0
	else:
		thread_timer = 0.0

func _exit_tree():
	thread.wait_to_finish()
