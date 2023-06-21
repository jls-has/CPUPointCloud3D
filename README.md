# CPUPointCloud3D

A Godot 4 plugin for creating static point clouds from mesh files.

Note:  Saving assets and scenes as binary (.mesh or .res instead of .tres / .scn instead of .tscn) will speed up your workflow.
To use:

1. Enable the plugin:
![image](https://github.com/jls-has/CPUPointCloud3D/assets/54590430/46525736-181d-4c8d-b9bb-f021cba609e0)

3. Load a 3D object as a .glb.  Ideally this will have Vertex, Color, and Normal information.
![image](https://github.com/jls-has/CPUPointCloud3D/assets/54590430/d4e5be96-c979-477e-9b26-1148182f0b7f)

4. Make the mesh unique and save. Recommend saving as "MyMeshName.mesh"

![image](https://github.com/jls-has/CPUPointCloud3D/assets/54590430/cae4ae01-b856-49f4-830b-5f1232fc7fbd)

5. Add a CPUPointCloud3D node

![image](https://github.com/jls-has/CPUPointCloud3D/assets/54590430/8f742067-f581-4d58-900a-35dced588c26)

6. Load your mesh

![image](https://github.com/jls-has/CPUPointCloud3D/assets/54590430/bdbe97d1-a6ca-4b3c-a9ea-3327ee70b4f8)

7.  Adjust Amount, MeshPointSize and any other particle properties to taste.

![image](https://github.com/jls-has/CPUPointCloud3D/assets/54590430/eeb86f21-443f-4aac-af92-3b180b07fce1)


## Godot version support

This plugin was created using Godot 4.0. The same method would work in Godot 3, but you would need to rewrite the script.
