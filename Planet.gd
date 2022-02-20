extends Spatial

func _init():
	VisualServer.set_debug_generate_wireframes(true)

func _input(event):
			
	if event is InputEventKey and Input.is_key_pressed(KEY_P):
		var vp = get_viewport()
		vp.debug_draw = (vp.debug_draw + 1 ) % 4
		
func _ready():
	get_children()[0].generate_mesh()

