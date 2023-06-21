@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type("CPUPointCloud3D", "CPUParticles3D", preload("static_point_cloud.gd"), preload("icon.svg"))
	pass


func _exit_tree() -> void:
	remove_custom_type("CPUPointCloud3D")
	pass
