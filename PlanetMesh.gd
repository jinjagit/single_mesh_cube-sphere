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
	
	var resolution := 10
	#var num_vertices : int = resolution * (resolution - 1) #+ (resolution * (resolution - 1))
	var num_vertices : int = resolution * (resolution - 1) * 2
	#var num_vertices : int = (resolution * (resolution - 1) * 4) + ((resolution - 2) *  (resolution - 2) * 2)
	
	var num_indices : int = ((resolution - 1) * (resolution - 1) * 6) + ((resolution - 1) * (resolution - 2) * 6)
	#var num_indices : int = (resolution - 1) * (resolution -2) * 12
	#var num_indices : int = (resolution - 1) * (resolution -1) * 36
	
	
	# up, front, down, back, left, right
	var faceNormals := [Vector3(0, 1, 0), Vector3(0, 0, -1), Vector3(0, -1, 0), Vector3(0, 0, -1), Vector3(-1, 0, 0), Vector3(1, 0, 0)]
	
	vertex_array.resize(num_vertices)
	uv_array.resize(num_vertices)
	normal_array.resize(num_vertices)
	index_array.resize(num_indices)
	
	var tri_index : int = 0
	

	var normal : Vector3 = faceNormals[0]
	var axisA := Vector3(normal.y, normal.z, normal.x)
	var axisB : Vector3 = normal.cross(axisA)
	for y in range(resolution - 1):
		for x in range(resolution):
			var i : int = x + y * resolution
			var percent := Vector2(x, y) / (resolution - 1)
			var pointOnUnitCube : Vector3 = normal + (percent.x - 0.5) * 2.0 * axisA + (percent.y - 0.5) * 2.0 * axisB
			
			vertex_array[i] = pointOnUnitCube
			#vertex_array[i] = _optimized_unit_sphere_point(pointOnUnitCube)
			
			# set the sets of 3 vertices for each triangle
			# But isn't this working on an intial single row of vertices?
			# Yes, but that doesn't matter for a single face, as it's simply setting the indices of vertices for triangles,
			# Including those not made yet.
			# Then this is skipped for last iteration of x and last iteration of y
			if x != resolution - 1 and y != resolution - 2:
				index_array[tri_index + 2] = i
				index_array[tri_index + 1] = i + resolution + 1
				index_array[tri_index] = i + resolution
				
				index_array[tri_index + 5] = i
				index_array[tri_index + 4] = i + 1
				index_array[tri_index + 3] = i + resolution + 1
				tri_index += 6
				
	normal = faceNormals[1]
	axisA = Vector3(normal.y, normal.z, normal.x)
	axisB = normal.cross(axisA)
	for y in range(resolution - 1):
		for x in range(resolution):
			var i : int = x + y * resolution + (resolution * (resolution - 1))
			var percent := Vector2(x, y) / (resolution - 1)
			var pointOnUnitCube : Vector3 = normal + (percent.x - 0.5) * 2.0 * axisA + (percent.y - 0.5) * 2.0 * axisB
			
			# rotate anticlockwise 90 degrees
			var rotatedPoint = Vector3(pointOnUnitCube.y * -1, pointOnUnitCube.x, pointOnUnitCube.z)
			
			vertex_array[i] = rotatedPoint
			#vertex_array[i] = _optimized_unit_sphere_point(rotatedPoint)
			
			if y == resolution - 2 and x > (resolution - 3):
				vertex_array[i] = rotatedPoint * 0.75
				
			# Add row of triangles between end of last plane and start of this one
			if y == 0 and x != resolution - 1:
				index_array[tri_index + 2] = i - resolution
				index_array[tri_index + 1] = i + 1
				index_array[tri_index] = i
				
				index_array[tri_index + 5] = i - resolution
				index_array[tri_index + 4] = i - resolution + 1
				index_array[tri_index + 3] = i + 1
				tri_index += 6
			
			# set the sets of 3 vertices for each triangle
			# But isn't this working on an intial single row of vertices?
			# Yes, but that doesn't matter for a single face, as it's simply setting the indices of vertices for triangles,
			# Including those not made yet.
			# Then this is skipped for last iteration of x and last iteration of y
			if x != resolution - 1 and y != resolution - 2:
				index_array[tri_index + 2] = i
				index_array[tri_index + 1] = i + resolution + 1
				index_array[tri_index] = i + resolution
				
				index_array[tri_index + 5] = i
				index_array[tri_index + 4] = i + 1
				index_array[tri_index + 3] = i + resolution + 1
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
	
	call_deferred("_update_mesh", arrays)#
	
func _update_mesh(arrays : Array):
	var _mesh := ArrayMesh.new()
	_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	self.mesh = _mesh
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate_object_local(Vector3(1, 0, 0), delta/2)
