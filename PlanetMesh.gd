tool
extends MeshInstance
class_name PlanetMesh

# Use https://catlikecoding.com/unity/tutorials/cube-sphere/
# to improve mapping cube points to sphere, so as to equalize
# areas of quadritalerals produced as much as possible
func _optimized_unit_sphere_point(pointOnUnitCube : Vector3):
	var x2 := pointOnUnitCube.x * pointOnUnitCube.x
	var y2 := pointOnUnitCube.y * pointOnUnitCube.y
	var z2 := pointOnUnitCube.z * pointOnUnitCube.z
	var sx := pointOnUnitCube.x * sqrt(1.0 - y2 / 2.0 - z2 / 2.0 + y2 * z2 / 3.0)
	var sy := pointOnUnitCube.y * sqrt(1.0 - x2 / 2.0 - z2 / 2.0 + x2 * z2 / 3.0)
	var sz := pointOnUnitCube.z * sqrt(1.0 - x2 / 2.0 - y2 / 2.0 + x2 * y2 / 3.0)			
	return Vector3(sx, sy, sz)

func generate_mesh():
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	
	var vertex_array := PoolVector3Array()
	var uv_array := PoolVector2Array()
	var normal_array := PoolVector3Array()
	var index_array := PoolIntArray()
	
	var resolution := 6
	var num_vertices : int = (resolution * (resolution - 1) * 4) + ((resolution - 2) * (resolution - 2))
	var num_indices : int = ((resolution - 1) * (resolution - 1) * 24) + ((resolution - 3) * (resolution - 3) * 6) + 24 + ((resolution -3) * 6)

	# up, front, down, back, left, right
	var faceNormals := [Vector3(0, 1, 0), Vector3(0, 0, -1), Vector3(0, -1, 0), Vector3(0, 0, 1), Vector3(1, 0, 0), Vector3(-1, 0, 0)]
	
	vertex_array.resize(num_vertices)
	uv_array.resize(num_vertices)
	normal_array.resize(num_vertices)
	index_array.resize(num_indices)
	
	var tri_index : int = 0
	
	for face in range(4):
		var normal : Vector3 = faceNormals[face]
		var axisA := Vector3(normal.y, normal.z, normal.x)
		var axisB : Vector3 = normal.cross(axisA)
		
		for y in range(resolution - 1):
			for x in range(resolution):
				var i : int = x + y * resolution + (resolution * (resolution - 1) * face)
				var percent := Vector2(x, y) / (resolution - 1)
				var pointOnUnitCube : Vector3 = normal + (percent.x - 0.5) * 2.0 * axisA + (percent.y - 0.5) * 2.0 * axisB
				
				# Rotations
				if face == 1:
					pointOnUnitCube = Vector3(pointOnUnitCube.y * -1, pointOnUnitCube.x, pointOnUnitCube.z)
				elif face == 2:
					pointOnUnitCube = Vector3(pointOnUnitCube.x * -1, pointOnUnitCube.y, pointOnUnitCube.z * -1)
				elif face == 3:
					pointOnUnitCube = Vector3(pointOnUnitCube.y, pointOnUnitCube.x * -1, pointOnUnitCube.z)
				
				vertex_array[i] = pointOnUnitCube
				#vertex_array[i] = _optimized_unit_sphere_point(pointOnUnitCube)
				
				#if face == 0 and y == resolution - 2 and x > resolution - 3:
					#vertex_array[i] = pointOnUnitCube * 0.75
					
				# Add row of triangles between end of last face and start of this one
				if face > 0 and y == 0 and x != resolution - 1:
					index_array[tri_index + 2] = i - resolution
					index_array[tri_index + 1] = i + 1
					index_array[tri_index] = i
					
					index_array[tri_index + 5] = i - resolution
					index_array[tri_index + 4] = i - resolution + 1
					index_array[tri_index + 3] = i + 1
					tri_index += 6
				
				# Set the triangle vertex indices for triangles between new rows of vertices
				if x != resolution - 1 and y != resolution - 2:
					index_array[tri_index + 2] = i
					index_array[tri_index + 1] = i + resolution + 1
					index_array[tri_index] = i + resolution
					
					index_array[tri_index + 5] = i
					index_array[tri_index + 4] = i + 1
					index_array[tri_index + 3] = i + resolution + 1
					tri_index += 6
			
				# Set the triangle vertex indices for final row of triangles between 3rd & 4th faces
				if face == 3 and y == resolution - 2 and x != resolution - 1:
					index_array[tri_index + 2] = i
					index_array[tri_index + 1] = x + 1
					index_array[tri_index] = x
					
					index_array[tri_index + 5] = i
					index_array[tri_index + 4] = i + 1
					index_array[tri_index + 3] = x + 1
					tri_index += 6
	
	var normal : Vector3 = faceNormals[5]
	var axisA := Vector3(normal.y, normal.z, normal.x)
	var axisB : Vector3 = normal.cross(axisA)				
	for y in range(1, resolution - 1, 1):
			for x in range(1, resolution - 1, 1):
				var i : int = (x - 1) + ((y - 1) * (resolution - 2)) + (resolution * (resolution - 1) * 4) # magic number 4 == 5th face
				var percent := Vector2(x, y) / (resolution - 1)
				var pointOnUnitCube : Vector3 = normal + (percent.x - 0.5) * 2.0 * axisA + (percent.y - 0.5) * 2.0 * axisB
				
				# Rotations

				vertex_array[i] = pointOnUnitCube
				#vertex_array[i] = _optimized_unit_sphere_point(pointOnUnitCube)
				
				# Set triangles for top left quad
				if x == 1 and y == 1:
					index_array[tri_index + 2] = 0
					index_array[tri_index + 1] = i
					index_array[tri_index] = (4 * resolution * (resolution -1)) - resolution
					
					index_array[tri_index + 5] = 0
					index_array[tri_index + 4] = resolution
					index_array[tri_index + 3] = i
					tri_index += 6
					
				#Set triangles for top row between corner quads
				if x < resolution - 2 and y == 1:
					index_array[tri_index + 2] = x * resolution
					index_array[tri_index + 1] = i + 1
					index_array[tri_index] = i
					
					index_array[tri_index + 5] = x * resolution
					index_array[tri_index + 4] = (x + 1) * resolution
					index_array[tri_index + 3] = i + 1
					tri_index += 6
				
				# Set triangles for top right quad
				if x == 1 and y == resolution - 2:
					index_array[tri_index + 2] = (3 * resolution * (resolution -1)) - resolution
					index_array[tri_index + 1] = (3 * resolution * (resolution -1)) + resolution
					index_array[tri_index] = i
					
					index_array[tri_index + 5] = (3 * resolution * (resolution -1)) - resolution
					index_array[tri_index + 4] = 3 * resolution * (resolution -1)
					index_array[tri_index + 3] = (3 * resolution * (resolution -1)) + resolution
					tri_index += 6
				
				# Set the triangle vertex indices for triangles to left of new vertices (as seen form inside cube)
				
				
				
				# Set the triangle vertex indices for triangles between top face edge and new rows of vertices
				
				
				# Set the triangle vertex indices for triangles between new rows of vertices
				if x < resolution - 2 and y < resolution - 2:
					index_array[tri_index + 2] = i
					index_array[tri_index + 1] = i + resolution + 1 - 2
					index_array[tri_index] = i + resolution - 2
					
					index_array[tri_index + 5] = i
					index_array[tri_index + 4] = i + 1
					index_array[tri_index + 3] = i + resolution + 1 - 2
					tri_index += 6
				
				# Set triangles for bottom left quad
				if x == resolution - 2 and y == 1:
					index_array[tri_index + 2] = (resolution * (resolution -1)) - resolution
					index_array[tri_index + 1] = (resolution * (resolution -1)) + resolution
					index_array[tri_index] = i
				
					index_array[tri_index + 5] = (resolution * (resolution -1)) - resolution
					index_array[tri_index + 4] = resolution * (resolution -1)
					index_array[tri_index + 3] = (resolution * (resolution -1)) + resolution
					tri_index += 6
				
					
				# Set the triangle vertex indices for triangles to right of new vertices (as seen form inside cube)
				
			
				# Set the triangle vertex indices for triangles between bottom face edge and new rows of vertices
				
				# Set triangles for bottom right quad
				if x == resolution - 2 and y == resolution - 2:
					index_array[tri_index + 2] = i
					index_array[tri_index + 1] = (2 * resolution * (resolution -1)) 
					index_array[tri_index] = (2 * resolution * (resolution -1)) + resolution
				
					index_array[tri_index + 5] = i
					index_array[tri_index + 4] = 2 * resolution * (resolution -1) - resolution
					index_array[tri_index + 3] = (2 * resolution * (resolution -1)) 
					tri_index += 6
				
				
	# Calculate normal for each triangle
	for a in range(0, index_array.size(), 3):
		var b : int = a + 1
		var c : int = a + 2
		var ab : Vector3 = vertex_array[index_array[b]] - vertex_array[index_array[a]]
		var bc : Vector3 = vertex_array[index_array[c]] - vertex_array[index_array[b]]
		var ca : Vector3 = vertex_array[index_array[a]] - vertex_array[index_array[c]]
		var cross_ab_bc : Vector3 = ab.cross(bc) * -1.0
		var cross_bc_ca : Vector3 = bc.cross(ca) * -1.0
		var cross_ca_ab : Vector3 = ca.cross(ab) * -1.0
		normal_array[index_array[a]] += cross_ab_bc + cross_bc_ca + cross_ca_ab
		normal_array[index_array[b]] += cross_ab_bc + cross_bc_ca + cross_ca_ab
		normal_array[index_array[c]] += cross_ab_bc + cross_bc_ca + cross_ca_ab
		
	# Normalize length of normals
	for i in range(normal_array.size()):
		normal_array[i] = normal_array[i].normalized()
		
	arrays[Mesh.ARRAY_VERTEX] = vertex_array
	arrays[Mesh.ARRAY_NORMAL] = normal_array
	arrays[Mesh.ARRAY_TEX_UV] = uv_array
	arrays[Mesh.ARRAY_INDEX] = index_array
	
	print("n vertices {v}".format({"v":vertex_array.size()}))
	print("n trianges {i}".format({"i":index_array.size() / 3.0}))
	
	call_deferred("_update_mesh", arrays)#
	
func _update_mesh(arrays : Array):
	var _mesh := ArrayMesh.new()
	_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	self.mesh = _mesh
	
	#rotate_object_local(Vector3(0, 0, 1), 3.3)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate_object_local(Vector3(1, 0, 0), delta/10)


# Notes on faces (r^2 == resolution * resolution):
#
# Top y+
# Edge A1: (0, resolution - 1, 1) = (min, max, step)
# Edge A2: (0, resolution * (resolution - 1), resolution)
# Edge A3: (resolution - 1, r^2 - 1, resolution)
# Edge A4: (resolution * (resolution - 1), r^2 - 1, resolution)
# 
# Back z-
# Edge B1 = A4
# Edge B2: (r^2, r^2 + (resolution * (resolution - 1)), resolution)
# Edge B3: (r^2 + resolution - 1, 2r^2 - 1, resolution)
# Edge B4: (r^2 + (resolution * (resolution - 1)), 2r^2 - 1, resolution)
# 
# Bottom y-
